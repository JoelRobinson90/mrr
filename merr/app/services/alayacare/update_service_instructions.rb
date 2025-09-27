# typed: true
# frozen_string_literal: true

module Alayacare
  class UpdateServiceInstructions < ApiClient
    def initialize(alayacare_id:, external_id:, text:)
      super()

      @alayacare_id = alayacare_id
      @external_id = external_id
      @text = text
    end

    def call

      if [@external_id, @alayacare_id].none?
        return OpenStruct.new(success?: false, error: "External_id or Alayacare_id required.")
      end

      if @external_id.present?
        local_visit = Visit.find_by(external_id: @external_id)
        address = local_visit&.patient&.address

        # Don't update if not needed
        if address&.notes == @text || (address&.notes.blank? && @text.blank?)
          return OpenStruct.new(success?: true, message: "No update needed.")
        end

        address&.update(notes: @text)
        url = "scheduler/visits/by_id/#{@external_id}"
      else
        url = "scheduler/visits/#{@alayacare_id}"
      end

      response = @api.put(url, {service_instructions: @text})

      # Need to update every future visit for that client in AC
      start_time = CGI.escape((Time.now - 1.day).iso8601)
      end_time = CGI.escape((Time.now + 1.year).iso8601)
      alayacare_client_id = JSON.parse(response.body)["alayacare_client_id"]
      query_string = "alayacare_client_id=#{alayacare_client_id}&start_at=#{start_time}&end_at=#{end_time}"
      future_visits = @api.get("scheduler/visits?#{query_string}")

      return future_visits unless future_visits.success?

      body = JSON.parse(future_visits.body)

      body["items"].each do |future_visit|
        @api.put("scheduler/visits/#{future_visit["alayacare_visit_id"]}", {service_instructions: @text})
      end

      response
    end
  end
end