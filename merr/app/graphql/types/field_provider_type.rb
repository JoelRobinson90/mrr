# frozen_string_literal: true

module Types
  class FieldProviderType < Types::BaseObject
    implements Types::UserAccount

    field :phone_number, String
    field :date_of_birth, String
    field :bio, String
    field :address, AddressType, null: false
    field :role, String
  end
end
