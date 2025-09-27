# frozen_string_literal: true

module Kustomer
  class UpdatePatient < ::ApplicationService
    attr_accessor :endpoint

    def initialize(patient, kustomer_id, additional_params = {})
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @endpoint = "customers/#{kustomer_id}"
      @patient = patient
    end

    def call
      @api.put(@endpoint, body)
    end

    def body
      k = PatientKustomer.new(@patient, additional_params)
      k.to_hash.transform_keys(&:to_s)
    end
  end
end
