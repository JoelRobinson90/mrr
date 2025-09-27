# typed: true
# frozen_string_literal: true

require "rest-client"

module Alayacare
  class Patient
    def self.get(id)
      path = "/patients/clients/#{id}"
      api = Authentication::Api.new(Authentication::AlayacareBroker)
      api.get(path)
    end

    def self.get_by_external_id(external_id)
      path = "/patients/clients/by_id/#{external_id}"
      api = Authentication::Api.new(Authentication::AlayacareBroker)
      api.get(path)
    end
  end
end
