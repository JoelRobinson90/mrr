# frozen_string_literal: true

module Alayacare
  module ServiceCodes
    def service_codes
      service_results = Rails.cache.fetch("ac_service_codes", expires_in: 1.hour) do
        services_response = @api.get("scheduler/service_codes")

        break nil unless services_response.success?

        body = JSON.parse(services_response.body)

        body["items"].map {|s| [s["name"], s["id"]] }.to_h
      end
      return {} if service_results.blank?

      service_results
    end
  end
end
