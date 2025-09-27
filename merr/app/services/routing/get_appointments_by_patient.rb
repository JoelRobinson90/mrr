# frozen_string_literal: true

module Routing
  class GetAppointmentsByPatient < ::ApplicationService
    include Helpers

    def initialize(patient, filter_canceled = true, visits_per_page: 100)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
      # NOTE: seems to work better when given times.

      @start_date = CGI.escape((Time.zone.now - 5.years).beginning_of_day.iso8601)
      @end_date = CGI.escape((Time.zone.now + 5.years).end_of_day.iso8601)
      @filter_canceled = filter_canceled
      @visits_per_page = visits_per_page
      @patient = patient
      @appointments = []
    end

    def call
      if @patient&.medical_record_number.blank?
        return OpenStruct.new(success?: false,
                              error:    "Patient missing medical record number")
      end

      # Recursive function since we don't know how many pages there will be
      fetch_appointments(page: 1)
    end

    def fetch_appointments(page:)
      url = "scheduler/visits?client_id=#{@patient.medical_record_number}"
      url += "&start_at=#{@start_date}&end_at=#{@end_date}&page=#{page}&count=#{@visits_per_page}"

      result = @api.get(url)
      return OpenStruct.new(success?: false, error: result.body) unless result.success?

      body = JSON.parse(result.body)

      body["items"].each do |visit|
        next if visit["cancelled"] && @filter_canceled
        fp_name = get_fp_name(visit["employee_id"])

        @appointments << instantiate_visit(visit: visit, fp_name: fp_name)
      end

      # Base case for recursive function
      if body["total_pages"] > page
        fetch_appointments(page: page + 1)
      else
        @appointments = @appointments.sort_by {|v| v[:start_time] }.reverse
        OpenStruct.new(success?: true, message: "Appointments fetched.", payload: @appointments)
      end
    end
  end
end
