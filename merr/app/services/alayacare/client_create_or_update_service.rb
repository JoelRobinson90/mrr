# typed: true
# frozen_string_literal: true

module Alayacare
  class ClientCreateOrUpdateService < ::ApplicationService
    attr_accessor :patient, :endpoint

    def initialize(patient, present_expected_fields, update_only = false)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
      @patient = patient
      @update_only = update_only

      @address = @patient.address
      @MRN = @patient.medical_record_number
      @demand_partner_name = @patient.demand_partner&.name
      @custom_attributes = @patient.ehr_custom_import_attributes
      @present_expected_fields = present_expected_fields
      @services = @custom_attributes.present? ? @custom_attributes.delete("services")&.split("|") : nil
    end

    def call
      return OpenStruct.new({success?: false, error: "Patient Id required"}) if @MRN.blank?

      @existing_patient_result = Alayacare::Patient.get_by_external_id(@MRN)

      formatted_body = body
      result = if formatted_body[:groups].nil?
                 OpenStruct.new({success?: false,
                                 error:    "Demand Partner #{@demand_partner_name} doesn't exist in Alayacare"})

               elsif @existing_patient_result.success?
                 @api.put("patients/clients/by_id/#{@MRN}", formatted_body)
               elsif @update_only
                 OpenStruct.new({success?: false, error: "Alayacare patient #{@MRN} not found"})
               else
                 create_result = @api.post("patients/clients", formatted_body)
                 if create_result.success?
                   add_status
                   progress_note_result = add_progress_note
                   return progress_note_result unless progress_note_result.success?
                 end

                 create_result
               end

      if result.success?
        add_services
      end

      result
    end

    def add_status
      # There is an automatic status of "pending" for new patients, so we need to forward date to override.
      @api.post("patients/clients/by_id/#{@MRN}/status", {effective_date: Time.zone.now + 1.minute, status: "active"})
    end

    def body
      demographics = {}
      base = {external_id: @MRN}

      demographics[:first_name] = @patient.first_name if should_include(:first_name)
      demographics[:last_name] = @patient.last_name if should_include(:last_name)
      demographics[:birthday] = @patient.date_of_birth if should_include(:date_of_birth)
      demographics[:gender] = sex_to_alayacare_gender if should_include(:sex)
      demographics[:phone_other] = @patient.secondary_phone_number if should_include(:secondary_phone_number)

      if should_include(:phone_number)
        demographics[:phone_personal] = @patient.phone_number
        demographics[:phone_main] = @patient.phone_number
      end

      demographics = demographics.merge(@custom_attributes) if @custom_attributes.present?

      if @address.present?
        demographics[:address] = @address.address_line_one if should_include(:address_line_one)
        demographics[:address_suite] = @address.address_line_two if should_include(:address_line_two)
        demographics[:city] = @address.city if should_include(:city)
        demographics[:state] = @address.state if should_include(:state)
        demographics[:zip] = @address.zipcode if should_include(:zipcode)

        base[:timezone] = ZipToTimezone.convert(@address.zipcode) if should_include(:zipcode)
      end

      base[:language] = @patient.preferred_language if should_include(:preferred_language)

      groups = fetch_groups
      base[:groups] = groups if groups.present?

      base[:demographics] = demographics if demographics.present?
      base
    end

    def fetch_groups
      return nil unless @demand_partner_name

      groups = Rails.cache.fetch("ac_demand_partner_groups", expires_in: 12.hours) do
        result = @api.get("patients/groups")
        break nil unless result.success?

        body = JSON.parse(result.body)
        break nil unless body["items"]

        body["items"].map {|item| item.slice("id", "name") }
      end

      return nil if groups.blank?

      groups.select {|item| item["name"] == @demand_partner_name }
    end

    def add_services
      return if @services.blank?

      service_codes = Rails.cache.fetch("ac_service_codes", expires_in: 1.hour) do
        services_response = @api.get("scheduler/service_codes")

        break nil unless services_response.success?

        body = JSON.parse(services_response.body)

        body["items"].map {|s| [s["name"], s["id"]] }.to_h
      end

      return if service_codes.blank?

      @services.each do |service|
        service_code_id = service_codes[service]
        next if service_code_id.blank?

        body = {client:                 {client_id: @MRN},
                service_code_id:        service_code_id,
                name:                   service,
                funding_methodology:    "single_funder",
                guid_funder_breakdowns: [{funder_id: 1, is_primary: 1, percentage: 100}]}

        @api.post("scheduler/services", body)
      end
    end

    def add_progress_note
      # WARNING: API endpoint for retrieving notes not working.
      # Check for existing progress note
      # existing_notes = @api.get("clinical/progress_notes/by_id/#{@MRN}?note_type=progress_patient_demographics")
      # return existing_notes unless existing_notes.success?
      # existing_notes_count = JSON.parse(existing_notes.body)["count"]
      # return OpenStruct.new({success?: true}) if existing_notes_count.to_i.positive?

      # Upload new progress note
      dob = @patient.date_of_birth ? @patient.date_of_birth.strftime("%m/%d/%Y") : ""
      note_content = {ID:            @MRN,
                      date_of_birth: dob,
                      sex:           @patient.sex}

      progress_note = {note_type: "progress_patient_demographics",
                       content:   build_progress_note_content(note_content)}

      @api.post("clinical/progress_notes/by_id/#{@MRN}", progress_note)
    end

    def build_progress_note_content(content)
      body = content.map {|k, v| "<li><b>#{k.to_s.humanize}:</b> #{v}</li>" }.join
      "<ul>#{body}</ul>"
    end

    def should_include(field)
      @present_expected_fields.include?(field.to_s) || @present_expected_fields.include?("all")
    end

    def sex_to_alayacare_gender
      case @patient.sex
      when "Male"
        "M"
      when "Female"
        "F"
      end
    end
  end
end
