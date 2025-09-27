module Types
  class ServiceType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :duration, Integer, null: false
    field :alayacare_id, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
