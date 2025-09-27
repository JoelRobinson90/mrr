# frozen_string_literal: true

module Kustomer
  class GetCustomerKlasses < ::ApplicationService
    attr_accessor :endpoint

    def initialize
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @endpoint = "metadata/customer"
    end

    def call
      @api.get(@endpoint)
    end
  end
end
