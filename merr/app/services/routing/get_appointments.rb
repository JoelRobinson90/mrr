# frozen_string_literal: true

module Routing
  class GetAppointments < ::ApplicationService
    include Helpers
    def initialize(start_date, end_date, filter_canceled = true, visits_per_page: 100, map_local_visits: false, patient: false)

      end_date = if end_date
                   CGI.escape((end_date += 1.day).end_of_day.iso8601)
                 else
                   CGI.escape((Time.zone.now + 1.year).end_of_day.iso8601)
                 end
      start_date = if start_date
                     CGI.escape(start_date.beginning_of_day.iso8601)
                   else
                     CGI.escape((Time.zone.now - 1.year).beginning_of_day.iso8601)
                   end

      @api = Authentication::Api.new(Authentication::AlayacareBroker)
      # NOTE: seems to work better when given times.
      @start_date = start_date
      @end_date = end_date
      @filter_canceled = filter_canceled
      @visits_per_page = visits_per_page
      @appointments = []
      # flag that decides wether or not to fetch local visits and map it on the response
      @map_local_visits = map_local_visits
      @patient = patient
    end

    def call
      # Recursive function since we don't know how many pages there will be
      fetch_appointments(page: 1)
    end

    def calculate_url(page)
      patient_segment = "client_id=#{@patient['medical_record_number']}" if @patient
      date_segment = "start_at=#{@start_date}&end_at=#{@end_date}"
      page_segment = "page=#{page}"
      count_segment = "count=#{@visits_per_page}"

      result = "scheduler/visits?"
      result += "&#{patient_segment}" if patient_segment
      result += "&#{date_segment}" if date_segment
      result += "&#{page_segment}" if page_segment
      result += "&#{count_segment}" if count_segment

      result
    end

    def fetch_appointments(page:)
      url = calculate_url(page)
      result = @api.get(url)
      return OpenStruct.new(success?: false, error: result.body) unless result.success?

      body = JSON.parse(result.body)

      # Batch load all patients and organize by client ID
      patient_h = get_patient_hash(body)
      body["items"].each do |visit|
        next if visit["employee_id"].blank?
        next if visit["cancelled"] && @filter_canceled

        patient = visit["client_id"].present? ? patient_h[visit["client_id"]] : nil

        # Get location from local patient, or fall back to Alayacare if not present
        location = if patient.present? && patient.address.present? && patient.address.longitude.present?
                     "#{patient.address.latitude},#{patient.address.longitude}"
                   else
                     # use internal_id in case the external_id is blank
                     profile("fetch_alayacare_patient_location") {fetch_alayacare_patient_location(visit["alayacare_client_id"])}
                   end

        demand_partner = fetch_alayacare_patient_demand_partner(visit["alayacare_client_id"], local_patient: patient)
        fp_name = get_fp_name(visit["employee_id"])
        @appointments << instantiate_visit(visit: visit, location: location, demand_partner: demand_partner,
                                           patient: patient, fp_name: fp_name, include_local_visit: @map_local_visits)
      end

      # Base case for recursive function
      if body["total_pages"] > page
        fetch_appointments(page: page + 1)
      else
        OpenStruct.new(success?: true, message: "Appointments fetched.", payload: @appointments)
      end
    end

    def get_patient_hash(body)
      client_ids = body["items"].map {|visit| visit["client_id"] }
      patients = Patient.includes(:address).where(medical_record_number: client_ids)
      patients.index_by(&:medical_record_number)
    end

    def fetch_alayacare_patient_location(internal_id)
      ac_patient = fetch_and_parse_patient(internal_id)
      return unless ac_patient

      ac_loc = ac_patient.dig("demographics", "location")
      ac_loc.present? && ac_loc["lat"].present? ? "#{ac_loc['lat']},#{ac_loc['lon']}" : nil
    end

    def fetch_alayacare_patient_demand_partner(internal_id, local_patient: nil)
      # if there's a local patient skip calling AC
      return local_patient.demand_partner.to_builder.attributes! if local_patient.present? && local_patient.demand_partner_id?

      ac_patient = fetch_and_parse_patient(internal_id)
      return unless ac_patient

      ac_group = ac_patient["groups"]

      ac_group.each do |group|
        dp = DemandPartner.find_by(name: group["name"])
        return dp.to_builder.attributes! if dp.present?
      end

      nil
    end

    def fetch_and_parse_patient(internal_id)
      result = Rails.cache.fetch("ac_patient_internal_id#{internal_id}", expires_in: 1.day) do
        @api.get("patients/clients/#{internal_id}")
      end

      return nil unless result.success?

      JSON.parse(result.body)
    end
  end
end
