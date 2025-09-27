# typed: true
# frozen_string_literal: true

module Alayacare
  class UpdateVisit < ApiClient

    # WARNING: This is only for 
    def initialize(alayacare_visit_id, fp_id:, start_time:, end_time:, service_instructions:)
      super()

      @alayacare_visit_id = alayacare_visit_id

      @body = {
        employee_id: fp_id,
        start_at: start_time,
        end_at: end_time,
        service_instructions: service_instructions
      }.compact

      @service_instructions = service_instructions
    end

    def call
      result = @api.put("scheduler/visits/#{@alayacare_visit_id}", @body)
      if result.success?
        parsed_response = JSON.parse(result.body)

        Alayacare::UpdateServiceInstructions.call(alayacare_id: @alayacare_visit_id,
                                                  external_id: nil,
                                                  text: @service_instructions)

        return OpenStruct.new({success?: true, payload: parsed_response})
      else
        return OpenStruct.new({success?: false, error: result.body})
      end
    end
  end
end
