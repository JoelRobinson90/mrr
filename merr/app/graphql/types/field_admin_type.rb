module Types
  class FieldAdminType < Types::BaseObject
    implements Types::UserAccount

    field :field_org_id, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
