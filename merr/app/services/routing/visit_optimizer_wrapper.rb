# frozen_string_literal: true

module Routing
  class VisitOptimizerWrapper < ::ApplicationService
    include Helpers
    attr_accessor :endpoint

    # -------------------------------------------------------------------
    #                       Algorithm versions
    # -------------------------------------------------------------------
    #   1 - Initial version
    #   2 - Don't average drive times for adjacent visits - cd1dbf76
    #   3 - Allow negative buffer - 5e9ba2e6
    #     - Grace period for overlapping visits - c1e54f76
    #   4 - Constrain to arrival window - bddc7b31
    #   5 - Allow drive time breakpoints - 398f7ab9
    #   6 - Filter by service areas - 37b5f7c6
    #   7 - Multi-resource scheduling - 45ae6d67

    def initialize(patient, start_date, end_date, visit_duration, current_user: nil, program_id: nil, existing_visit_id: nil, fp_ids_to_filter_to: nil, arrival_window: nil, resource_requirements: nil, ignore_existing_visit_conflicts: true)
      @start_date = start_date.to_date
      @end_date = end_date.to_date

      @visit_duration = visit_duration
      @user_name = current_user&.full_name || "unknown user"

      address = patient.address
      @visit_geo = "#{address.latitude},#{address.longitude}"

      @resource_requirements = resource_requirements

      @existing_visit_id = existing_visit_id
      existing_visit = Visit.find_by(external_id: existing_visit_id)
      @previous_arrival_window = [existing_visit&.arrival_window_start, existing_visit&.arrival_window_end]

      @arrival_window = arrival_window
      @ignore_existing_visit_conflicts = ignore_existing_visit_conflicts

      @drive_time_breakpoints = nil
      @minutes_of_buffer_time = 15
      @max_results = nil
      @hours_before_first_option = 10
      @max_distance = 300
      @max_grace_period = 0
      # weights must add up to 100
      @score_weights = {
        drive_weight:                    80,
        proximity_weight:                10,
        utilization_weight:              10,
        shift_shortening_penalty_weight: 0
      }

      @rank_thresholds = {
        high_rank_percentile_threshold:   90,
        medium_rank_percentile_threshold: 60,
        high_rank_absolute_threshold:     90,
        medium_rank_absolute_threshold:   60
      }

      @demand_partner_short_name = ""

      @virtual_provider_offset = nil
      @enforce_service_area = false

      program = Program.find_by(id: program_id)
      if program
        @minutes_of_buffer_time = program.minutes_of_buffer_time
        @drive_time_breakpoints = program.drive_time_breakpoints
        @max_results = program.max_results
        @hours_before_first_option = program.hours_before_first_option
        @max_distance = program.max_straight_line_distance_in_miles
        @max_grace_period = program.max_grace_period
        @min_shift_length = program.min_shift_length_in_hours
        @arrival_window_block_schedule = program.arrival_window_block_schedule
        @arrival_window_offset_minutes = program.arrival_window_offset_minutes
        @demand_partner_short_name = program.demand_partner&.short_name
        @virtual_provider_offset = program.virtual_provider_offset
        @enforce_service_area = program.enforce_service_area

        unless fp_ids_to_filter_to
          fetched_fp_ids = fetch_fp_ids_for_pt(patient.external_id) if program.use_fp_pt_association
          @fp_ids_for_pt = fetched_fp_ids if fetched_fp_ids&.length&.positive?
        end

        @score_weights = {
          drive_weight:                    program.drive_weight,
          proximity_weight:                program.proximity_weight,
          utilization_weight:              program.utilization_weight,
          shift_shortening_penalty_weight: program.shift_shortening_penalty_weight
        }

        @rank_thresholds = {
          high_rank_percentile_threshold:   program.high_rank_percentile_threshold,
          medium_rank_percentile_threshold: program.medium_rank_percentile_threshold,
          high_rank_absolute_threshold:     program.high_rank_absolute_threshold,
          medium_rank_absolute_threshold:   program.medium_rank_absolute_threshold
        }
      end
      @program = program
      @patient = patient

      patient_geo = PatientGeo.where(patient: patient, program: program).first
      @service_area = patient_geo&.service_area

      @fp_ids_for_pt = fp_ids_to_filter_to if fp_ids_to_filter_to

      @run_id = SecureRandom.uuid
      @run_start_time = Time.zone.now

      @soonest_allowed_time = Time.zone.now
      # Reschedule flows can be booked immediately
      @soonest_allowed_time += @hours_before_first_option.hours unless @existing_visit_id

      initial_log_hash = {
        run_id:                           @run_id,
        scheduler_version:                7,
        request_time:                     @run_start_time,
        rescheduling:                     @existing_visit_id.present?,
        user:                             current_user,
        patient:                          patient,
        visit_location:                   @visit_geo,
        start_date:                       @start_date,
        end_date:                         @end_date,
        buffer_time:                      @minutes_of_buffer_time,
        max_results:                      @max_results,
        max_grace_period:                 @max_grace_period,
        high_rank_percentile_threshold:   @rank_thresholds[:high_rank_percentile_threshold],
        medium_rank_percentile_threshold: @rank_thresholds[:medium_rank_percentile_threshold],
        high_rank_absolute_threshold:     @rank_thresholds[:high_rank_absolute_threshold],
        medium_rank_absolute_threshold:   @rank_thresholds[:medium_rank_absolute_threshold],
        drive_time_breakpoints:           @drive_time_breakpoints,
        virtual_provider_offset:          @virtual_provider_offset,
        enforce_service_area:             @enforce_service_area,
        service_area_id:                  @service_area&.id
      }
      initial_log_hash.merge!(@score_weights)

      @scheduler_log = SchedulerLog.create(initial_log_hash)
      unless @scheduler_log.persisted?
        log_message("SchedulerLog creation failed: #{@scheduler_log.errors.full_messages.to_sentence}")
      end
    end

    def call
      shifts = profile("get shifts") do
        Routing::GetShifts.call(@start_date, @end_date, anchor_location:       @visit_geo,
                                                        max_distance:          @max_distance,
                                                        run_id:                @run_id,
                                                        assigned_fp_ids:       @fp_ids_for_pt,
                                                        resource_requirements: @resource_requirements)
      end

      unless shifts.success?
        log_message("Error fetching shifts: #{shifts.error}", level: :error)
        @scheduler_log.update(visit_error_message: "Shift fetching error: #{shifts.error}")
        return shifts
      end

      @shifts = filter_shifts_by_demand_partner_and_service_area(shifts)

      visits = profile("get visits") do
        if Flipper.enabled?(:use_local_visits_for_scheduler)
          fp_filter_list = @virtual_provider_offset.present? ? nil : @shifts.map {|s| s[:fp_id] }.uniq.compact
          Routing::GetVisitsForOptimizer.call(@start_date, @end_date, fp_filter_list: fp_filter_list)
        else
          Routing::GetAppointments.call(@start_date, @end_date)
        end
      end

      unless visits.success?
        log_message("Error fetching appointments: #{visits.error}", level: :error)
        @scheduler_log.update(visit_error_message: "Visit fetching error: #{visits.error}")
        return visits
      end

      @visits = visits.payload

      if @existing_visit_id.present? && @ignore_existing_visit_conflicts
        @visits.reject! {|visit| visit[:visit_id] == @existing_visit_id }
      end

      parameters = {
        run_id:                  @run_id,
        start_date:              @start_date,
        end_date:                @end_date,
        visit_duration:          @visit_duration,
        visit_geo:               @visit_geo,
        arrival_window:          @arrival_window,
        previous_arrival_window: @previous_arrival_window,
        patient_timezone:        @patient&.address&.timezone,
        rescheduling:            @existing_visit_id.present?,
        program_id:              @program&.id,
        resource_requirements:   @resource_requirements,
        preferred_providers:     get_preferred_providers(@patient)
      }

      options = {
        minutes_of_buffer_time:           @minutes_of_buffer_time,
        max_results:                      @max_results,
        hours_before_first_option:        @hours_before_first_option,
        max_distance:                     @max_distance,
        max_grace_period:                 @max_grace_period,
        min_shift_length:                 @min_shift_length,
        arrival_window_block_schedule:    @arrival_window_block_schedule,
        arrival_window_offset_minutes:    @arrival_window_offset_minutes,
        drive_weight:                     @score_weights[:drive_weight],
        proximity_weight:                 @score_weights[:proximity_weight],
        utilization_weight:               @score_weights[:utilization_weight],
        shift_shortening_penalty_weight:  @score_weights[:shift_shortening_penalty_weight],
        high_rank_percentile_threshold:   @rank_thresholds[:high_rank_percentile_threshold],
        medium_rank_percentile_threshold: @rank_thresholds[:medium_rank_percentile_threshold],
        high_rank_absolute_threshold:     @rank_thresholds[:high_rank_absolute_threshold],
        medium_rank_absolute_threshold:   @rank_thresholds[:medium_rank_absolute_threshold],
        drive_time_breakpoints:           @drive_time_breakpoints,
        virtual_provider_offset:          @virtual_provider_offset
      }

      internal_result = profile("run visit optimizer") do
        VisitOptimizer.call(@shifts, @visits, parameters, options)
      end

      return internal_result unless internal_result.success?

      options = internal_result.payload[:options]
      @slots = internal_result.payload[:slots]
      @initial_slots_count = internal_result.payload[:initial_slots_count]
      @pre_merge_slots = internal_result.payload[:pre_merge_slots]
      @pre_merge_slots_count_by_role = internal_result.payload[:pre_merge_slots_count_by_role]
      @shifts_count_by_role = internal_result.payload[:shifts_count_by_role]

      record_analytics(@visits, @shifts, options)

      # Give more feedback when availability not found.
      msg = "Visit options fetched"
      if @shifts.blank?
        msg = "No shifts scheduled within #{@max_distance} miles of patient."
        @shifts_count_by_role.each do |role, shift_count|
          msg += " No shifts for #{role.humanize(capitalize: false)}s." if shift_count.zero?
        end
      elsif @initial_slots_count.zero?
        msg = "No open time slots found for this area."
        @pre_merge_slots_count_by_role.each do |role, slot_count|
          msg += " No slots for #{role.humanize(capitalize: false)}s." if slot_count.zero?
        end
      elsif options.blank?
        msg = "No open time slots available for this patient due to drive times."
      end

      OpenStruct.new(success?: true, message: msg, payload: options)
    rescue StandardError => e
      Sentry.capture_exception(e)
      log_message("Optimizer crashed: #{e.message} - #{e.backtrace}", level: :error)
      @scheduler_log.update(visit_error_message: "Optimizer crashed: #{e.message}")

      OpenStruct.new(success?: false, error: e.message)
    end

    def filter_shifts_by_demand_partner_and_service_area(shifts)
      # always filter shifts by demand partner
      filters = [@demand_partner_short_name&.downcase]

      # if flag is set, also filter shifts by service area name
      filters << @service_area&.name&.downcase if @enforce_service_area
      # allow a shift if its location name includes ALL the filter terms
      # patient with no service area can book any shift for now
      shifts.payload.select do |shift|
        filters.compact.map {|target| shift[:location_name]&.downcase&.include? target }.all?
      end
    end

    def get_preferred_providers(patient)
      # TODO: Refresh from Athena

      patient.preferred_providers.map {|provider| provider.external_id}
    end

    #-----------------------------------------------------
    #                Helper methods
    #-----------------------------------------------------

    def record_analytics(visits, shifts, options)
      log_hash = {
        existing_visits_count:         visits.length,
        existing_visits_dump:          format_log_dump(visits, :visits),
        shifts_count:                  shifts.length,
        shifts_dump:                   format_log_dump(shifts, :shifts),
        shifts_count_by_role:          @shifts_count_by_role,
        initial_slots_count:           @initial_slots_count,
        pre_merge_slots:               @pre_merge_slots,
        pre_merge_slots_count_by_role: @pre_merge_slots_count_by_role,
        valid_slots_count:             @slots.length,
        options_count:                 options.length,
        grace_period_options_count:    options.select {|o| (o[:grace_period]).positive? }.length,
        options_dump:                  format_log_dump(options, :options)
      }

      add_disposition(log_hash, options)

      log_message("Visit optimizer run by #{@user_name} for location #{@visit_geo} from #{@start_date} to #{@end_date}")
      log_message("Buffer time: #{@minutes_of_buffer_time} minutes, Max results: #{@max_results}, First option: #{@hours_before_first_option} hours, Max distance: #{@max_distance} miles")

      if @run_start_time.present?
        elapsed_time = Time.zone.now - @run_start_time
        log_message("Elapsed time: #{elapsed_time} seconds")
        log_hash[:elapsed_time_for_results] = elapsed_time.to_i
      end

      log_message("Existing appointments seen: #{visits.length}")
      log_message("Existing appointments dump: #{format_log_dump(visits, :visits)}")

      log_message("Shifts found: #{shifts.length}")
      log_message("Shifts dump: #{format_log_dump(shifts, :shifts)}")

      log_message("Initial slots: #{@initial_slots_count}")
      log_message("Valid slots: #{@slots.length}")
      log_message("Valid slots dump: #{format_log_dump(@slots, :slots)}")

      log_message("Options shown: #{options.length}")
      log_message("Options dump: #{format_log_dump(options, :options)}")

      unless options.empty?
        days_until_soonest_option = (options.pluck(:start_time).min - Time.zone.now) / 60 / 60 / 24
        log_message("Days until soonest option: #{days_until_soonest_option}")
        log_message("Best drive time: #{options.first[:expected_drive]}") #FIXME:  This is wrong!!!
        log_message("Worst drive time: #{options.last[:expected_drive]}")

        log_hash[:days_until_soonest_option] = days_until_soonest_option if days_until_soonest_option.present?
        log_hash[:best_drive_time] = options.first[:expected_drive]
        log_hash[:worst_drive_time] = options.last[:expected_drive]
      end

      no_preferred = 0
      not_all_preferred = 0
      options.each do |option|
        preferences = option[:resources].map {|resource| resource[:preferred] }

        no_preferred += 1 if preferences.none?
        not_all_preferred += 1 unless preferences.all?
      end

      log_hash[:options_without_any_preferred_provider_count] = no_preferred
      log_hash[:options_without_full_preferred_provider_count] = not_all_preferred

      unless @scheduler_log.update(log_hash)
        log_message("SchedulerLog update failed: #{@scheduler_log.errors.full_messages.to_sentence}")
      end
    end

    def add_disposition(log_hash, options)
      zero_shift_roles = zero_count_roles(@shifts_count_by_role)
      if zero_shift_roles.present?
        log_hash[:disposition] = :no_shifts
        log_hash[:blocking_roles] = zero_shift_roles
      elsif @initial_slots_count.zero?
        log_hash[:disposition] = :no_slots
        log_hash[:blocking_roles] = zero_count_roles(@pre_merge_slots_count_by_role)
      elsif options.blank?
        log_hash[:disposition] = :no_options
      else
        log_hash[:disposition] = :options_shown
      end
    end

    def zero_count_roles(count_by_role)
      count_by_role.map {|role, count| count.zero? ? role : nil }.compact.sort.join(",")
    end

    def format_log_dump(items, schema)
      return "" if items.empty?

      keys = case schema
             when :visits
               %w[fp_id start_time end_time location]
             when :shifts
               %w[fp_name fp_id start_time end_time location]
             when :options
               %w[fp_name fp_id start_time end_time total_score rank_category]
             when :slots
               %w[fp_name fp_id start_time end_time origin_drive_time destination_drive_time expected_drive
                  grace_period]
             else
               return ""
             end

      items.map do |item|
        item = item.to_h
        keys.map {|key| item[key.to_sym] }.join(" | ")
      end.join(" ~|~ ")
    end

    def fetch_fp_ids_for_pt(pt_external_id)
      ac_api = Authentication::Api.new(Authentication::AlayacareBroker)
      ac_patient = ac_api.get("patients/clients/by_id/#{pt_external_id}")
      # Note that AC doesn't give us any way to validate that the employees we're
      # looking at are actually field providers, but as we're including the class name
      # in our auto-generated external IDs, we should not see duplicate external IDs
      # across employee types
      care_team = JSON.parse(ac_patient.body)["care_team"]
      care_team&.select do |employee|
        fp = FieldProvider.find_by(external_id: employee["external_id"])
      end&.map {|fp| fp["external_id"] }
    end
  end
end
