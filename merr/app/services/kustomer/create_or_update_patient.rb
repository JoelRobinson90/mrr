# frozen_string_literal: true

module Kustomer
  class CreateOrUpdatePatient < ::ApplicationService
    attr_accessor :endpoint

    def initialize(patient, present_expected_fields, additional_params = {}, update_only = false)
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @patient = patient
      @additional_params = additional_params
      @update_only = update_only
      @present_expected_fields = present_expected_fields
      @body = body
    end

    def call
      begin
        kustomer_id = Helper.get_kustomer_id(@api, @patient["medical_record_number"])
        resp = send_patient_to_kustomer(kustomer_id)

        if resp.success? == false && resp.error == "duplicate phone"
          @body["sharedPhones"] = @body["phones"]
          @body.delete("phones")
          resp = send_patient_to_kustomer(kustomer_id)
        end

        return resp
      rescue StandardError => e
        Sentry.capture_exception(e)
        return OpenStruct.new({success?: false, error: e.message})
      end
    end

    def body
      k = PatientKustomer.new(@patient, @additional_params, @present_expected_fields)
      k.to_hash.transform_keys(&:to_s)
    end

    def send_patient_to_kustomer(kustomer_id)
      if kustomer_id.present?
        # update
        Helper.parse_response(@api.put("customers/#{kustomer_id}", @body))
      elsif @update_only == false
        # create
        Helper.parse_response(@api.post("customers", @body))
      else
        OpenStruct.new({success?: false,
                        error:    "Update only mode enabled, but could not find the patient"})
      end
    end
  end
end
