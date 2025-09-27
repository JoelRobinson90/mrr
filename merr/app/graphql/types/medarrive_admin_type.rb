# frozen_string_literal: true

module Types
  class MedarriveAdminType < Types::BaseObject
    implements Types::UserAccount

    field :phone_number, String, null: true
  end
end
