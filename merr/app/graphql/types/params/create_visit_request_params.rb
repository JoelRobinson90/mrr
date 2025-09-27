# frozen_string_literal: true

module Types
  module Params
    class CreateVisitRequestParams < GraphQL::Schema::InputObject
      argument :patient, CreatePatientParams
      # TODO: accept program_id and service_ids when they are passed in from the form
      # argument :program_id, ID, required: false
      # argument :service_ids, [ID], required: false
    end
  end
end
