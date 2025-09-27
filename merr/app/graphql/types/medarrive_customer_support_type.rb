module Types
  class MedarriveCustomerSupportType < Types::BaseObject
    implements Types::UserAccount

    field :phone_number, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
