module Types
  class VisitResourceRequirementType < Types::BaseObject
    field :id, ID, null: false
    field :visit_type_id, Integer, null: true
    field :provider_role, String, null: false
    field :duration, Integer, null: false
    field :offset, Integer, null: true
    field :in_home, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :use_preferred_provider, Boolean, null: true
  end
end
