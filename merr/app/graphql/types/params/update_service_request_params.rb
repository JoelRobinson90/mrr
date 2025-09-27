# frozen_string_literal: true

module Types
  module Params
    class UpdateServiceRequestParams < GraphQL::Schema::InputObject
      argument :status, String, required: false
      argument :status_detail, String, required: false
      argument :refusal_reason, String, required: false
    end
  end
end
