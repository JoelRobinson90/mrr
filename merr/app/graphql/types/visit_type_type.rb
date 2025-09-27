# frozen_string_literal: true

module Types
  class VisitTypeType < Types::BaseObject
    field :id, ID, null: false
    field :ma_id, ID, null: false
    field :name, String, null: false
    field :duration, Integer, null: false
    field :alayacare_id, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :services, [Types::ServiceType], null: false
    field :plus_ones_enabled, Boolean, null: true
    field :requirements, [Types::VisitResourceRequirementType], method: :visit_resource_requirements, null: false
    field :outreach_visit, Boolean, null: false
  end
end
