# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :account, Types::UserAccount, null: false
    field :display_name, String, method: :full_name, null: false
    field :account_type, String, null: true
  end
end
