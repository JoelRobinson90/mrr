# frozen_string_literal: true

module Types
  module Params
    class CreateVisitGroupParams < GraphQL::Schema::InputObject
      graphql_name "CreateVisitGroupParams"
      argument :patient_id, Integer, required: false
      argument :visit_id, Integer, required: false
    end
  end
end
