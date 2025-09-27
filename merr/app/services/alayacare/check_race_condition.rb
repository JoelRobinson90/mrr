# typed: true
# frozen_string_literal: true

module Alayacare
  class CheckRaceCondition < ApiClient
    include Routing::Helpers

    def initialize(visit)
      super()

      @visit = visit
      @start_time_obj = visit.start_time

      buffer = @visit&.program&.minutes_of_buffer_time&.minutes || 15.minutes
      buffer -= @visit&.program&.max_grace_period&.minutes || 0.minutes
      @safe_buffer = buffer - 1.minute
    end

    def call
      return OpenStruct.new({success?: true}) if @visit.field_provider.blank?

      # TODO: optimize by only fetching one FP
      # TODO: actually check drive time
      result = Routing::GetAppointments.call(@visit.start_time - 4.hours, @visit.end_time + 4.hours)
      return OpenStruct.new({success?: false, error: "Can not fetch AC visits to check race condition"}) unless result.success?

      existing_appointments = result.payload.filter {|ac_visit| ac_visit[:fp_id].to_s == @visit.field_provider.external_id }

      return OpenStruct.new({success?: true}) if existing_appointments.blank?

      # Make sure there's at least 15 minutes between appointments
      existing_appointments.each do |existing_appt|
        conflict = @visit.start_time < (existing_appt[:end_time] + @safe_buffer) &&
                   @visit.end_time > (existing_appt[:start_time] - @safe_buffer)

        if conflict
          err = "Visit conflicts with existing visit from #{existing_appt[:start_time]} to #{existing_appt[:end_time]}"
          return OpenStruct.new({success?: false, error: err})
        end
      end

      return OpenStruct.new({success?: true})
    end
  end
end
