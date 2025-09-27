# typed: true
# frozen_string_literal: true

module Athena
  class InitiateVisitCheckIn < ApiClient
    def initialize(visit)
      super()
      @visit = visit
    end

    def call
      return OpenStruct.new(success?: true) unless @visit.should_push_to_athena?
      
      result = @api.post("appointments/#{@visit.athena_id}/startcheckin", {})
      log_athena_result(result)

      # get encounter id
      result = @api.get("appointments/#{@visit.athena_id}")
      if result.success?
        body = JSON.parse(result.body)
        @visit.paper_trail.update_columns("athena_encounter_id" => body[0]["encounterid"])
      end
      encounter_id = @visit.athena_encounter_id

      # add services
      if encounter_id.present?
        @visit.services.each do |service|
          next if service.athena_id.blank?

          result = @api.post("chart/encounter/#{encounter_id}/encounterreasons",
                             {encounterreasonid: service.athena_id})
          log_athena_result(result)
        end
      end
    end

    def log_athena_result(result)
      err = if result.success?
              body = JSON.parse(result.body)
              body["success"] ? nil : body["errormessage"] || body["message"]
            else
              result.body
            end

      # Check-in is idempotent.
      return if err == "Appointment may have already started the check in process."

      if err
        msg = "Athena API error: #{@visit.ma_id} - #{err}"
        p msg
        Sentry.capture_message(msg)
      end
    end
  end
end
