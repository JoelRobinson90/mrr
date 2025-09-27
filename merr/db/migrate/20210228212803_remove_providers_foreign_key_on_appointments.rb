# typed: false
class RemoveProvidersForeignKeyOnAppointments < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :appointments, :providers, column: :field_provider_id
  end
end
