# frozen_string_literal: true

# TODO
# add current_user context
# restrict access to accessible demand partners
# return appointments?
# field level access?

module Types
  class DemandPartnerType < Types::BaseObject
    field :id, ID
    field :name, String
    field :created_at, GraphQL::Types::ISO8601DateTime
    field :updated_at, GraphQL::Types::ISO8601DateTime
    field :patients, [Types::PatientType]
  end
end
