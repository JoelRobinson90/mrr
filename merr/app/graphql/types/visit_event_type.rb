module Types
  class VisitEventType < Types::BaseObject
    field :id, ID, null: false
    field :event_type, String, null: false
    field :location, String, null: false
    field :time, GraphQL::Types::ISO8601DateTime, null: false
    field :field_provider, Types::FieldProviderType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
