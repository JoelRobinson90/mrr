# frozen_string_literal: true

module Routing
  class VisitOptimizer < ::ApplicationService
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

    def initialize(shifts, visits, parameters, options)
      @start_date = parameters[:start_date].to_date
      @end_date = parameters[:end_date].to_date

      @run_id = parameters[:run_id]

      @visit_duration = parameters[:visit_duration]

      @resource_requirements = parameters[:resource_requirements]

      if @resource_requirements.blank?
        @resource_requirements = [
          {
            in_home:       true,
            provider_role: "field_provider",
            duration:      @visit_duration,
            offset:        0
          }
        ]
      end

      role_counts = @resource_requirements.map {|rr| [rr[:provider_role], 0] }.to_h
      @shifts_count_by_role = role_counts.dup
      @pre_merge_slots_count_by_role = role_counts.dup

      # Process in-home providers first, so that when we
      # merge slots, the FP is retained for backwards compatibility.
      @resource_requirements = @resource_requirements.sort_by {|req| req[:in_home] ? 0 : 1 }

      @virtual_only_visit = @resource_requirements.pluck(:in_home).none?

      # Only used for virtual_provider_offset filtering
      @program_id = parameters[:program_id]

      @shifts = shifts
      @visits = visits

      @arrival_window = parameters[:arrival_window]
      @previous_arrival_window = parameters[:previous_arrival_window]
      @limit_arrival_times = @arrival_window.respond_to?(:length) && @arrival_window.length == 2 && @arrival_window.all?

      @visit_geo = parameters[:visit_geo]

      @preferred_providers = parameters[:preferred_providers] || []

      @api_base = "https://maps.googleapis.com/maps/api/distancematrix/json"

      @minutes_of_buffer_time = options[:minutes_of_buffer_time]
      @max_results = options[:max_results]
      @hours_before_first_option = options[:hours_before_first_option]
      @max_distance = options[:max_distance]
      @max_grace_period = options[:max_grace_period]
      @min_shift_length = options[:min_shift_length]

      @score_weights = {
        drive_weight:                    options[:drive_weight],
        proximity_weight:                options[:proximity_weight],
        utilization_weight:              options[:utilization_weight],
        shift_shortening_penalty_weight: options[:shift_shortening_penalty_weight]
      }

      @rank_thresholds = {
        high_rank_percentile_threshold:   options[:high_rank_percentile_threshold],
        medium_rank_percentile_threshold: options[:medium_rank_percentile_threshold],
        high_rank_absolute_threshold:     options[:high_rank_absolute_threshold],
        medium_rank_absolute_threshold:   options[:medium_rank_absolute_threshold]
      }

      @drive_time_breakpoints = options[:drive_time_breakpoints]

      @virtual_provider_offset = options[:virtual_provider_offset]

      @patient_timezone = parameters[:patient_timezone]
      @arrival_window_block_schedule = options[:arrival_window_block_schedule]
      @arrival_window_offset_minutes = options[:arrival_window_offset_minutes]

      current_time = options[:current_time] || Time.zone.now

      @earliest_time = [@start_date.beginning_of_day, current_time + @hours_before_first_option.hours].min
      @latest_time = @end_date.end_of_day

      @soonest_allowed_time = current_time
      # Reschedule flows can be booked immediately
      @soonest_allowed_time += @hours_before_first_option.hours unless parameters[:rescheduling]

      @use_custom_drive_time_service = options[:use_custom_drive_time_service]

      @pre_merge_slots = {}
    end

    def call
      @slots = nil

      profile("generate_slot_options") do
        @resource_requirements.each do |resource_requirement|
          current_role = resource_requirement[:provider_role]
          shifts = @shifts.select {|shift| shift[:provider_role] == current_role }
          visits = @visits.select {|visit| shifts.pluck(:fp_id).include? visit[:fp_id] }

          @shifts_count_by_role[current_role] += shifts.length

          new_slots = generate_slot_options(shifts, visits, resource_requirement)

          slot_dump = new_slots.map {|ns| ns.slice(:fp_id, :start_time, :end_time) }
          @pre_merge_slots[current_role] = slot_dump

          @pre_merge_slots_count_by_role[current_role] += slot_dump.length

          @slots = merge_slots(@slots, new_slots)

          # Filter out slots that have shrunk below visit duration
          @slots = @slots.select {|slot| slot_length_exceeds_duration(slot) }
        end
      end

      profile("calculate_drive_times") { @slots = calculate_drive_times }
      @slots = constrain_slots_to_arrival_window if @limit_arrival_times
      @slots = filter_slot_proximity
      initial_slots_count = @slots.length

      profile("rank_slots") { @slots = rank_slots }
      profile("add_arrival_windows") { @slots = add_arrival_windows }

      options = @slots.map {|slot| format_options_hash(slot) }

      options = profile("filter options") do
        options = filter_virtual_provider_offset(options, @visits)

        options = filter_proximity(options)
        options = filter_visit_conflicts(options, @visits)
        if @limit_arrival_times
          options = filter_start_time_outside_of_arrival_window(options)
          options = filter_to_one_option_per_provider(options)
        end

        # similarity filter should be called last
        options = filter_similarity(options)
      end

      options = options.slice(0, @max_results) if @max_results.present? && @max_results.positive?

      payload = {
        options:                       options,
        slots:                         @slots,
        initial_slots_count:           initial_slots_count,
        pre_merge_slots:               @pre_merge_slots,
        pre_merge_slots_count_by_role: @pre_merge_slots_count_by_role,
        shifts_count_by_role:          @shifts_count_by_role
      }

      OpenStruct.new(success?: true, payload: payload)
    end

    def generate_slot_options(shifts, visits, resource_requirement)
      duration = resource_requirement[:duration]

      # If the requirement has an offset, then the slot start_time
      # is pushed earlier since the visit can start before this
      # person is free.
      offset = resource_requirement[:offset] || 0

      if resource_requirement[:in_home]
        grace_period = @max_grace_period
        buffer = @minutes_of_buffer_time
      else
        grace_period = 0
        buffer = 0
      end

      slots = []
      shifts.each_with_index do |shift, shift_index|
        blocks = visits.select do |visit|
          is_blocking(visit, shift) && (visit[:location].present? || !resource_requirement[:in_home])
        end

        blocks = blocks.sort_by {|block| block[:start_time] }

        blocks.each_with_index do |block, i|
          # For the first blocking visit the preceeding location is where the shift starts.
          # For all other blocking visits, the preceeding location is the last visit.
          # Buffer is needed between any two visits, but not between an visit and a shift boundary.
          if i.zero?
            preceeding_time = shift[:start_time]
            preceeding_location = shift[:location]
          else
            preceeding_time = blocks[i - 1][:end_time]
            preceeding_location = blocks[i - 1][:location]
          end

          # Add a slot between this block and the last
          slots << {
            fp_id:              block[:fp_id],
            fp_name:            shift[:fp_name],
            start_time:         preceeding_time - offset.minutes,
            end_time:           block[:start_time],
            origin:             preceeding_location,
            destination:        block[:location],
            shift_index:        shift_index,
            origin_buffer:      i.zero? ? 0 : buffer,
            destination_buffer: buffer,
            provider_role:      shift[:provider_role]
          }

          # Add a slot after the last blocking visit.
          next unless i == blocks.size - 1

          slots << {
            fp_id:              block[:fp_id],
            fp_name:            shift[:fp_name],
            start_time:         block[:end_time] - offset.minutes,
            end_time:           shift[:end_time],
            origin:             block[:location],
            destination:        shift[:location],
            shift_index:        shift_index,
            origin_buffer:      buffer,
            destination_buffer: 0,
            provider_role:      shift[:provider_role]
          }
        end

        # If a shift doesn't have any blockers, just make a slot for the whole thing.
        next unless blocks.empty?

        slots << {
          fp_id:              shift[:fp_id],
          fp_name:            shift[:fp_name],
          start_time:         shift[:start_time] - offset.minutes,
          end_time:           shift[:end_time],
          origin:             shift[:location],
          destination:        shift[:location],
          shift_index:        shift_index,
          origin_buffer:      0,
          destination_buffer: 0,
          provider_role:      shift[:provider_role]
        }
      end

      # add resources
      slots.each do |slot|
        slot[:resources] = [
          {
            resource_id:   slot[:fp_id],
            offset:        offset,
            in_home:       resource_requirement[:in_home],
            name:          slot[:fp_name],
            provider_role: slot[:provider_role]
          }
        ]
      end

      slots.select {|slot| slot_length_exceeds_duration(slot) }
    end

    def merge_slots(slots, new_slots)
      return new_slots if slots.nil?

      merged_slots = []
      slots.each do |slot|
        new_slots.each do |new_slot|
          overlap = find_overlap(slot[:start_time],
                                 slot[:end_time],
                                 new_slot[:start_time],
                                 new_slot[:end_time])

          next unless overlap

          overlap_start, overlap_end = overlap

          merged_slot = slot.dup
          merged_slot[:start_time] = overlap[0]
          merged_slot[:end_time] = overlap[1]
          # avoid pass by reference issue wnen merging lists
          merged_slot[:resources] = slot[:resources].dup.concat(new_slot[:resources])

          # if merging into a driving slot, adjust the buffer if the
          # slot boundary is constrained by a virtual slot.
          # This prevents virtual shifts from blocking on drive time.
          if slot[:resources].pluck(:in_home).any?
            merged_slot[:origin_buffer] -= (overlap_start - slot[:start_time]).to_i / 60
            merged_slot[:destination_buffer] -= (slot[:end_time] - overlap_end).to_i / 60
          end

          merged_slots << merged_slot
        end
      end
      merged_slots
    end

    def constrain_slots_to_arrival_window
      filtered_slots = []

      @slots.each do |slot|
        adjusted_drive_times = add_buffer_to_drive_times(slot)

        # adjust arrival window for drive times
        adjusted_arrival_window_start = @arrival_window[0] - adjusted_drive_times[:origin].minutes
        adjusted_arrival_window_end = @arrival_window[1] +
                                      @visit_duration.minutes +
                                      adjusted_drive_times[:destination].minutes

        # Find overlap of existing slot time range and arrival window time range
        overlap = find_overlap(slot[:start_time],
                               slot[:end_time],
                               adjusted_arrival_window_start,
                               adjusted_arrival_window_end)

        # Only keep slot if an overlap is found
        next if overlap.blank?

        overlap_start, overlap_end = overlap

        # Need to track of whether we are contiguous with a visit or shift boundary
        # If a slot boundary is changed by the arrival window it is no longer contiguous
        slot[:non_contiguous_start] = slot[:start_time] != overlap_start
        slot[:non_contiguous_end] = slot[:end_time] != overlap_end

        slot[:start_time] = overlap_start
        slot[:end_time] = overlap_end

        filtered_slots << slot
      end
      filtered_slots
    end

    def calculate_drive_times
      drive_time_slots = []

      if @virtual_only_visit
        return @slots.map do |slot|
          slot[:origin_drive_time] = 0
          slot[:destination_drive_time] = 0
          slot
        end
      end

      @slots.in_groups_of(25).each do |slot_group|
        slot_group = slot_group.compact

        origins = slot_group.pluck(:origin)
        destinations = slot_group.pluck(:destination)

        incoming_times = get_drive_time_array(origins, [@visit_geo])
        outgoing_times = get_drive_time_array([@visit_geo], destinations)

        # TODO: error handling here

        slot_group.each_with_index do |slot, i|
          slot[:origin_drive_time] = incoming_times[i]
          slot[:destination_drive_time] = outgoing_times[i]
        end

        drive_time_slots.concat(slot_group)
      end

      drive_time_slots
    end

    def rank_slots
      @slots = @slots.select {|slot| is_valid(slot) }

      # This can add additional slots
      @slots = @slots.map {|slot| find_visit_times_in_slot(slot) }.flatten

      @slots = @slots.map do |slot|
        result = SlotScorer.call(slot, @shifts[slot[:shift_index]], @visits, @score_weights,
                                 @earliest_time, @latest_time, @minutes_of_buffer_time, @min_shift_length, @drive_time_breakpoints)
        slot[:scores] = result.payload
        log_message("Slot scoring failed: #{result.error}") unless result.success?
        slot
      end

      @slots = @slots.sort_by {|slot| slot[:scores][:precise_score] }.reverse

      # must be done after ranking
      @slots = add_rank_categories(@slots, @rank_thresholds)
    end

    #-----------------------------------------------------
    #                Helper methods
    #-----------------------------------------------------

    def get_drive_time_array(origins, destinations)
      return get_valhalla_drive_time_array(origins, destinations) if @use_custom_drive_time_service

      destinations = CGI.escape(destinations.join("|"))
      origins = CGI.escape(origins.join("|"))
      token = "AIzaSyBepKqwdkNKFWWydPgtaxSJNUlpAR4h3fM"

      query = "?destinations=#{destinations}&origins=#{origins}&key=#{token}"

      result = RestClient.get(@api_base + query)

      if result.code != 200
        return result.body # handle this return
      end

      # TODO: better error handling here

      body = JSON.parse(result.body)

      # There can be one or more rows with a sub-array of elements
      # This merges it down to one array.

      element_list = body["rows"]&.map {|row| row["elements"] }.reduce(&:+)

      element_list.map do |element|
        return nil if element["status"] == "ZERO_RESULTS"

        element["duration"]["value"] / 60
      end
    end

    def valhalla_format_geo(location)
      lat, lon = location.split(",")
      {lat: lat.to_f, lon: lon.to_f}
    end

    def get_valhalla_drive_time_array(origins, destinations)
      destinations = destinations.map {|loc| valhalla_format_geo(loc) }
      origins = origins.map {|loc| valhalla_format_geo(loc) }
      url = "#{EnvHelper.env_or_nil('VALHALLA_URL_BASE')}/sources_to_targets"

      data = {sources: origins, targets: destinations, costing: "auto",
              directions_options: {units: "miles"}}.to_json

      result = RestClient.post(url, data)

      if result.code != 200
        return result.body # handle this return
      end

      body = JSON.parse(result.body)

      body["sources_to_targets"]&.flatten&.map {|leg| leg["time"] / 60 }
    end

    def add_rank_categories(options, rank_thresholds)
      if options.length.positive?
        min_high_score_i_position = 0
        min_medium_score_i_postion = 0

        options.each_with_index do |_option, i|
          percentile = 100 - normalized_value(i, max: options.length - 1)

          # since we start at the 100% percentile and count down, this will get us the lowest i position for the
          # high and medium category
          if percentile >= rank_thresholds[:high_rank_percentile_threshold]
            min_high_score_i_position = i
          elsif percentile >= rank_thresholds[:medium_rank_percentile_threshold]
            min_medium_score_i_postion = i
          end
        end

        # get the score of the lowest option in each category
        min_highest_score = options[min_high_score_i_position][:scores][:total_score]
        min_medium_score = options[min_medium_score_i_postion][:scores][:total_score]

        options.each_with_index do |option, i|
          # compare to score thresholds and set a category
          category = if option[:scores][:total_score] >= min_highest_score
                       :high
                     elsif option[:scores][:total_score] >= min_medium_score
                       :medium
                     else
                       :low
                     end

          # there should always be at least one "high"
          category = :high if i.zero?

          # anything above high_rank_override is high
          # anything above medium_rank_override is _at least_ medium.
          if option[:scores][:total_score] >= rank_thresholds[:high_rank_absolute_threshold]
            category = :high
          elsif option[:scores][:total_score] >= rank_thresholds[:medium_rank_absolute_threshold]
            category = :medium unless category == :high
          end

          option[:rank_category] = category
        end
      end
      options
    end

    def add_arrival_windows
      @slots.each do |slot|
        result = GetArrivalWindow.call(slot[:appt_start], @patient_timezone, @arrival_window_block_schedule,
                                       @arrival_window_offset_minutes, @previous_arrival_window)
        if result.success?
          slot[:arrival_window_start] = result.payload[0]
          slot[:arrival_window_end] = result.payload[1]
        end
      end
      @slots
    end

    def is_valid(slot)
      return false unless slot[:origin_drive_time].present? && slot[:destination_drive_time].present?

      adjusted_drive_times = add_buffer_to_drive_times(slot)

      time_needed = adjusted_drive_times[:origin] + @visit_duration + adjusted_drive_times[:destination]

      time_availible = (slot[:end_time] - slot[:start_time]) / 60

      slot[:grace_period] = [0, time_needed - time_availible].max.to_i

      slot[:grace_period] <= @max_grace_period
    end

    def make_appt_slot(slot, params)
      new_slot = slot.dup.merge(params)
      new_slot[:resources] = new_slot[:resources].map do |resource|
        offset = resource[:offset] || 0
        {
          resource_id:   resource[:resource_id],
          start_time:    new_slot[:appt_start] + offset.minutes,
          end_time:      new_slot[:appt_end],
          in_home:       resource[:in_home],
          name:          resource[:name],
          provider_role: resource[:provider_role],
          preferred:     @preferred_providers.include?(resource[:resource_id])
        }
      end
      new_slot
    end

    def find_visit_times_in_slot(slot)
      adjusted_drive_times = add_buffer_to_drive_times(slot)
      grace_period_adjustment = (slot[:grace_period] / 2).minutes
      average_drive_time = (slot[:origin_drive_time] + slot[:destination_drive_time]) / 2

      early_start = slot[:start_time] + adjusted_drive_times[:origin].minutes - grace_period_adjustment
      early_slot = make_appt_slot(slot, {
                                    appt_start:     early_start,
                                    appt_end:       early_start + @visit_duration.minutes,
                                    expected_drive: slot[:origin_drive_time],
                                    contiguous:     slot[:non_contiguous_start] ? false : true
                                  })

      late_end = slot[:end_time] - adjusted_drive_times[:destination].minutes + grace_period_adjustment
      late_slot = make_appt_slot(slot, {
                                   appt_start:     late_end - @visit_duration.minutes,
                                   appt_end:       late_end,
                                   expected_drive: slot[:destination_drive_time],
                                   contiguous:     slot[:non_contiguous_end] ? false : true
                                 })

      if late_slot[:appt_start] - early_slot[:appt_end] < 1.hour && !@limit_arrival_times
        return early_slot[:expected_drive] > late_slot[:expected_drive] ? [late_slot] : [early_slot]
      end

      slots_list = [early_slot, late_slot]
      extra_slot_time = early_slot[:appt_end] + 1.hour

      while extra_slot_time + @visit_duration.minutes + 1.hour < late_slot[:appt_start]
        break unless @visit_duration.positive?

        extra_slot = make_appt_slot(slot, {
                                      appt_start:     extra_slot_time,
                                      appt_end:       extra_slot_time + @visit_duration.minutes,
                                      expected_drive: average_drive_time,
                                      contiguous:     false
                                    })

        slots_list << extra_slot

        extra_slot_time = extra_slot[:appt_end] + 1.hour
      end

      slots_list
    end

    def format_options_hash(slot)
      {
        fp_id:                          slot[:fp_id],
        fp_name:                        slot[:fp_name],
        start_time:                     slot[:appt_start],
        end_time:                       slot[:appt_end],
        cx_start:                       round_time_15(slot[:appt_start]),
        cx_end:                         round_time_15(slot[:appt_end]),
        expected_drive:                 slot[:expected_drive],
        run_id:                         @run_id,
        total_score:                    slot[:scores][:total_score],
        drive_score:                    slot[:scores][:drive_score],
        proximity_score:                slot[:scores][:proximity_score],
        utilization_score:              slot[:scores][:utilization_score],
        shift_shortening_penalty_score: slot[:scores][:shift_shortening_penalty_score],
        rank_category:                  slot[:rank_category],
        grace_period:                   slot[:grace_period],
        arrival_window_start:           slot[:arrival_window_start],
        arrival_window_end:             slot[:arrival_window_end],
        resources:                      slot[:resources]
      }
    end

    def filter_proximity(options)
      # filter out past visit options or options that start too soon
      options.select {|option| option[:start_time] > @soonest_allowed_time }
    end

    def filter_slot_proximity
      # pre-filter slots that couldn't possibly fit a visit, to improve error messages.
      @slots.select {|slot| slot[:end_time] > @soonest_allowed_time }
    end

    def filter_visit_conflicts(options, visits)
      # any visits without location haven't been acounted for
      danger_visits = visits.select {|visit| visit[:location].blank? }
      log_message("#{danger_visits.length} appointments without location seen")

      new_options = options.select do |option|
        danger_visits.map {|visit| is_blocking(option, visit) }.none?
      end

      blocked_options_count = options.length - new_options.length
      log_message("#{blocked_options_count} options blocked by appointments without location")

      if blocked_options_count.positive?
        log = SchedulerLog.find_by(run_id: @run_id)
        log.update(options_blocked_by_no_location_visit: blocked_options_count) if log.present?
      end

      new_options
    end

    def add_buffer_to_drive_times(slot)
      # drive times can never be less than zero even with negative buffer
      {
        origin:      [0, (slot[:origin_drive_time] + slot[:origin_buffer])].max,
        destination: [0, (slot[:destination_drive_time] + slot[:destination_buffer])].max
      }
    end

    def filter_similarity(options)
      distinct_options = []
      options.group_by {|option| "#{option[:cx_start]}#{option[:fp_id]}" }.each do |_unique_key, option_group|
        # Already in priority order, so to remove duplicates, just take the first
        distinct_options << option_group[0]
      end

      distinct_options
    end

    def filter_to_one_option_per_provider(options)
      distinct_options = []
      options.group_by {|option| (option[:fp_id]).to_s }.each do |_unique_key, option_group|
        # Already in priority order, so to remove duplicates, just take the first
        distinct_options << option_group[0]
      end

      distinct_options
    end

    def filter_start_time_outside_of_arrival_window(options)
      # It's possible that the grace period allows a start time out of the
      # required range, so we need to filter those out.
      arrival_window_range = @arrival_window[0]..@arrival_window[1]
      options.select {|option| arrival_window_range.cover? option[:start_time] }
    end

    def filter_virtual_provider_offset(options, visits)
      same_program_visits = visits.select {|visit| visit[:program_id] == @program_id }

      options.select do |option|
        same_program_visits.map {|visit| is_blocking_virtual_provider(visit, option) }.none?
      end
    end

    def is_blocking_virtual_provider(existing, prospective)
      return false if @virtual_provider_offset.blank?

      range_start = existing[:start_time] - @virtual_provider_offset.minutes
      range_end = existing[:start_time] + @virtual_provider_offset.minutes

      (range_start..range_end).include? prospective[:start_time]
    end

    def slot_length_exceeds_duration(slot)
      minimum_duration = @visit_duration +
                         [slot[:origin_buffer], 0].max +
                         [slot[:destination_buffer], 0].max -
                         @max_grace_period

      (slot[:end_time] - slot[:start_time]) / 60 >= minimum_duration
    end

    def find_overlap(start1, end1, start2, end2)
      overlap_start = [start1, start2].max
      overlap_end = [end1, end2].min

      return nil unless overlap_end > overlap_start

      [overlap_start, overlap_end]
    end
  end
end
