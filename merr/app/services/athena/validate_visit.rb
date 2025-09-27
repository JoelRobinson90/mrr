# typed: true
# frozen_string_literal: true

module Athena
  class ValidateVisit < ApiClient
    def initialize(visit)
      super()
      @visit = visit
    end

    def call
      if @visit.athena_id.blank?
        return OpenStruct.new(success?: true)
      end

      # Only need to validate reschedules.
      unless (@visit.start_time_changed? || @visit.field_provider_id_changed?)
        return OpenStruct.new(success?: true)
      end

      result = @api.get("appointments/#{@visit.athena_id}")

      return result unless result.success?

      payload = JSON.parse(result.body)

      athena_status = payload.dig(0, "encounterstatus") || payload.dig(0, "encounterstate")
      check_in_started = payload.dig(0, "startcheckin").present?

      if check_in_started
        err = "Can't reschedule visit after check-in (encounter #{athena_status}). Cancel visit and then reschedule."
        OpenStruct.new(success?: false, error: err)
      else
        OpenStruct.new(success?: true)
      end
    end
  end
end