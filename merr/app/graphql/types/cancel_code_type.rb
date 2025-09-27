module Types
  class CancelCodeType < Types::BaseObject
    field :id, ID, null: false
    field :alayacare_id, Integer, null: true
    field :code, String, null: false
    field :description, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
