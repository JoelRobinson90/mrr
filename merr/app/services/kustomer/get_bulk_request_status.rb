# typed: true
# frozen_string_literal: true

module Kustomer
  class GetBulkRequestStatus < ::ApplicationService
    attr_accessor :endpoint

    def initialize(id)
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @endpoint = "bulk/#{id}"
    end

    def call
      @api.get(endpoint)
    end
  end
end
