# frozen_string_literal: true

module Types
  class VisitResourceType < Types::BaseObject
    field :resource_id, String, null: false
    field :start_time, String, null: false
    field :end_time, String, null: false
    field :in_home, Boolean, null: false
    field :preferred, Boolean, null: false
    field :name, String
    field :provider_role, String
  end
end
