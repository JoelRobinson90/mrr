# frozen_string_literal: true

module Types
  class AddressType < Types::BaseObject
    field :id, ID
    field :address_line_one, String
    field :address_line_two, String
    field :city, String
    field :state, String
    field :zipcode, String
    field :created_at, GraphQL::Types::ISO8601DateTime
    field :updated_at, GraphQL::Types::ISO8601DateTime
    field :latitude, String
    field :longitude, String
    field :notes, String
    field :timezone, String
    field :addressable_type, String
    field :addressable_id, Integer
    field :county, String
    field :geocoding_partial_match, Boolean
    field :geocoding_approximate_result, Boolean
  end
end
