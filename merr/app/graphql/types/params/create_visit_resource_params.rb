# frozen_string_literal: true

module Types
  module Params
    class CreateVisitResourceParams < GraphQL::Schema::InputObject
      argument :resource_id, String, required: true
      argument :start_time, String, required: true
      argument :end_time, String, required: true
      argument :in_home, Boolean, required: true
    end
  end
end
