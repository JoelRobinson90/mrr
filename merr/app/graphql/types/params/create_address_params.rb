# frozen_string_literal: true

module Types
  module Params
    class CreateAddressParams < GraphQL::Schema::InputObject
      argument :state,
               String,
               required: true
      argument :address_line_one, String
      argument :address_line_two, String, required: false
      argument :city, String
      argument :zipcode, String
      argument :county, String, required: false
    end
  end
end
