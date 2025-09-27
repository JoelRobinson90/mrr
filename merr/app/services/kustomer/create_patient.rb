# typed: true
# frozen_string_literal: true

module Kustomer
  class CreatePatient < ::ApplicationService
    attr_accessor :endpoint

    def initialize(patient, additional_params)
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @endpoint = "customers"
      @patient = patient
      @additional_params = additional_params
    end

    def call
      @api.post(@endpoint, body)
    end

    def body
      k = PatientKustomer.new(@patient, @additional_params)
      k.to_hash.transform_keys(&:to_s)
    end
  end
end
