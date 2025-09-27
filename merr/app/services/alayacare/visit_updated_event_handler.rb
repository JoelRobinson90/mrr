# typed: true
# frozen_string_literal: true

module Alayacare
  class VisitUpdatedEventHandler < ApiClient
    def initialize(visit_external_id)
      super()
      @visit_external_id = visit_external_id
    end

    def call
      log_prefix = "SQS event processor:"
      visit = Visit.find_by(external_id: @visit_external_id)

      # If there is no local visit, clear the event from the queue since we don't handle it.
      if visit.blank?
        Rails.logger.error("#{log_prefix} Could not find visit from external_id: #{@visit_external_id}")
        return OpenStruct.new(success?: true, message: "No visit to update")
      end

      ac_visit_response = @api.get("scheduler/visits/by_id/#{visit.external_id}")

      unless ac_visit_response.success?
        msg = "#{log_prefix} Alayacare returned #{ac_visit_response.code}"
        Rails.logger.error msg
        return OpenStruct.new(success?: false, error: msg)
      end

      ac_visit = begin
        JSON.parse(ac_visit_response.body)
      rescue StandardError
        nil
      end

      visit.alayacare_status = ac_visit["status"]
      visit.start_time = ac_visit["start_at"]
      visit.end_time = ac_visit["end_at"]

      if ac_visit["cancelled"]
        cancel_code = CancelCode.find_by(code: ac_visit.dig("cancel_code", "code"))
        visit.mark_canceled(cancel_code.id) if cancel_code.present?
      end

      visit.skip_push_to_external = true

      unless visit.save
        msg = "#{log_prefix} Visit #{visit.external_id} failed to save. #{visit.errors.full_messages.to_sentence}"
        Rails.logger.error msg
        return OpenStruct.new(success?: false, error: msg)
      end

      result = UpdateWorkSessions.call(visit, ac_visit["work_sessions"]) if ac_visit["work_sessions"].present?

      unless result.success?
        Rails.logger.error "Could not update work sessions for #{@visit_external_id}: #{result.error}"
        return result
      end

      OpenStruct.new(success?: true, message: "#{log_prefix} Updated visit and work sessions (#{result.message})")
    end
  end
end
