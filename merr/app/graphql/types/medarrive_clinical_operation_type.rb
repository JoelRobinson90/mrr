# frozen_string_literal: true

module Types
  class MedarriveClinicalOperationType < Types::BaseObject
    implements Types::UserAccount

    field :phone_number, String, null: true
  end
end
