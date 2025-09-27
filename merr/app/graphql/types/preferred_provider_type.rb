module Types
  class PreferredProviderType < Types::BaseObject
    field :fp_id, String, null: false
    field :display_name, String, null: false
    field :role, String, null: true
  end
end
