# frozen_string_literal: true

module Kustomer
  class GetPatient < ::ApplicationService
    attr_accessor :endpoint

    def initialize(patient)
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @endpoint = "customers/externalId=#{patient.medical_record_number}"
    end

    def call
      @api.get(@endpoint)
    end
  end
end
