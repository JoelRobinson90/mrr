# frozen_string_literal: true

# typed: true
module Kustomer
  class CustomerService < ::ApplicationService
    attr_accessor :endpoint

    def initialize(customer_id)
      @customer_id = customer_id
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @endpoint = "customers"
    end

    def call
      path = [endpoint, @customer_id].join("/")
      @api.get(path)
    end
  end
end
