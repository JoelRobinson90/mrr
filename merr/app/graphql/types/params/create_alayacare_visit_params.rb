# frozen_string_literal: true

module Types
  module Params
    class CreateAlayacareVisitParams < GraphQL::Schema::InputObject
      argument :patient_id, ID, required: true
      argument :program_id, ID, required: true
      argument :visit_type_id, ID, required: true
      argument :field_provider_external_id, String, required: true
      argument :service_ids, [ID], required: true
      argument :visit_request_id, ID, required: false
      argument :start_time, String, required: true
      argument :end_time, String, required: true
      argument :service_instructions, String, required: false
      argument :resources, [Types::Params::CreateVisitResourceParams]

      # argument :external_id, String, required: true
    end
  end
end
