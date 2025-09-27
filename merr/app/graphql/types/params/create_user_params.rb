# frozen_string_literal: true

module Types
  module Params
    class CreateUserParams < GraphQL::Schema::InputObject
      argument :email,
               String,
               required: true
    end
  end
end
