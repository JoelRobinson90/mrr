# frozen_string_literal: true

module Types
  module Params
    class UpdateAlayacareVisitParams < GraphQL::Schema::InputObject
      argument :alayacare_visit_id, String, required: false
      argument :external_id, String, required: false
      argument :start_time, String, required: true
      argument :end_time, String, required: true
      argument :field_provider_id, String, required: false
      argument :patient_id, String, required: true
      argument :service_instructions, String, required: false
      argument :canceled, Boolean, required: false
      argument :resources, [Types::Params::CreateVisitResourceParams]
      argument :service_ids, [ID], required: false
      argument :visit_type_id, ID, required: false
    end
  end
end
