# frozen_string_literal: true

module Types
  class CreatorType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false

    field :display_name, String, method: :full_name, null: false
  end
end
