# frozen_string_literal: true

module Alayacare
  class CancelCodes < ::ApplicationService
    def initialize
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
    end

    def call
      results = Rails.cache.fetch("ac_cancel_codes", expires_in: 1.hour) do
        response = @api.get("scheduler/cancelcodes")

        break nil unless response.success?

        body = JSON.parse(response.body)

        body["items"]
      end
      return [] if results.blank?

      results
    end
  end
end
