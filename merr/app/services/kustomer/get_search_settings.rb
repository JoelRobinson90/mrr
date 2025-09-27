# frozen_string_literal: true

module Kustomer
  class GetSearchSettings < ::ApplicationService
    attr_accessor :endpoint

    def initialize(search_id)
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @endpoint = "customers/searches/#{search_id}"
    end

    def call
      Kustomer::Helper.parse_response(@api.get(endpoint))
    end
  end
end
