# typed: true
# frozen_string_literal: true

module Alayacare
  class ClientCreateVisit < ApiClient
    include Routing::Helpers

    def initialize(patient, start_time, end_time, service_code_id, field_provider_ac_external_id = nil, service_instructions = "", skip_validation: false,
                   run_id: "", index_chosen: nil, expected_drive_time: nil, fp_name: nil, scheduling_start: nil, total_picks: nil, current_user: nil)
      super()

      @patient = patient
      @start_time = start_time
      @end_time = end_time
      @MRN = patient&.medical_record_number
      @service_code_id = service_code_id
      @field_provider_ac_external_id = field_provider_ac_external_id
      @service_instructions = service_instructions
      @skip_validation = skip_validation
      @user_name = current_user&.full_name || "unknown user"

      @start_time_obj = start_time.instance_of?(String) ? Time.zone.parse(start_time) : start_time
      @end_time_obj = end_time.instance_of?(String) ? Time.zone.parse(end_time) : end_time

      @run_id = run_id
      @fp_name = fp_name
      @expected_drive_time = expected_drive_time
      @index_chosen = index_chosen
      @scheduling_start = scheduling_start
      @total_picks = total_picks

      @scheduler_log = SchedulerLog.find_by(run_id: run_id)
    end

    def call
      return OpenStruct.new({success?: false, error: "Patient Id required"}) if @MRN.blank?

      record_analytics

      unless visit_valid? || @skip_validation
        log_message("Race condition conflict found", level: :error)
        @scheduler_log&.update(blocked_for_race_condition: true)
        return OpenStruct.new({success?: false,
                               error:    "Visit time already taken"})
      end

      @existing_patient_result = @api.get("patients/clients/by_id/#{@MRN}")

      Alayacare::ClientCreateOrUpdateService.call(@patient, ["all"]) unless @existing_patient_result.success?

      result = create_visit

      if result.success?
        @scheduler_log&.update(visit_created: true)
      else
        err_msg = "Visit creation failed: #{result.body}"
        log_message(err_msg, level: :error)
        @scheduler_log&.update(visit_error_message: err_msg)
      end

      result
    end

    def record_analytics
      log_message("#{(Time.zone.now - @scheduling_start) / 60} minutes since scheduling started") if @scheduling_start

      log_message("Total picks before booking: #{@total_picks}")
      log_message("Visit booked at #{Time.zone.now} by #{@user_name}")
      log_message("Visit info: #{@fp_name} from #{@start_time} to #{@end_time}")
      log_message("Index chosen: #{@index_chosen}")
      log_message("Expected drive time: #{@expected_drive_time}")
    end

    def visit_valid?
      return true if @field_provider_ac_external_id.blank?

      # TODO: optimize by only fetching one FP
      # TODO: actually check drive time
      result = Routing::GetAppointments.call(@start_time_obj - 4.hours, @end_time_obj + 4.hours)
      return false unless result.success?

      existing_appointments = result.payload.filter {|visit| visit[:fp_id].to_s == @field_provider_ac_external_id.to_s }

      log_message("Nearby appointments: #{existing_appointments.map do |appt|
                                            "#{appt[:start_time]}-#{appt[:end_time]}"
                                          end.join(' ')}")

      return true if existing_appointments.blank?

      # Make sure there's at least 15 minutes between appointments
      existing_appointments.map do |existing_appt|
        @start_time_obj < (existing_appt[:end_time] + 14.minutes) &&
          @end_time_obj > (existing_appt[:start_time] - 14.minutes)
      end.none?
    end

    def create_visit
      service_response = add_service(service_code_id: @service_code_id)
      if service_response.success?
        service_id = service_response[:id]
      else
        return service_response
      end

      unless @start_time
        return OpenStruct.new({success?: false,
                               body:     {message: "Start time needs to be set"}})
      end
      unless @end_time
        return OpenStruct.new({success?: false,
                               body:     {message: "End time needs to be set"}})
      end

      @api.post("scheduler/visits", {
                  client_id:            @MRN,
                  start_at:             @start_time,
                  end_at:               @end_time,
                  alayacare_service_id: service_id,
                  employee_id:          @field_provider_ac_external_id.to_s,
                  service_instructions: @service_instructions
                })
    end

    private

    def add_service(service_code_id:)
      unless service_code_id
        return OpenStruct.new({success?: false,
                               body:     {message: "service_code_id must be present"}})
      end

      service_body = {
        client:                 {
          client_id: @MRN
        },
        service_code_id:        service_code_id,
        name:                   "Visit for patient: #{@patient.full_name}",
        funding_methodology:    "single_funder", #  what's this ?
        guid_funder_breakdowns: [{funder_id: 1, is_primary: 1, percentage: 100}] #  what's this ?
      }

      service_result = @api.post("scheduler/services", service_body)

      if service_result.success?
        body = JSON.parse(service_result.body)

        return OpenStruct.new({success?: true, id: body["id"]})
      end
      service_result
    end
  end
end
