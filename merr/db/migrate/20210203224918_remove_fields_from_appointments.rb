# typed: false
class RemoveFieldsFromAppointments < ActiveRecord::Migration[6.0]
  def change
    remove_column :appointments, :published_at, :datetime
    remove_column :appointments, :medical_reference_number, :string
    remove_column :appointments, :reason, :string
    remove_column :appointments, :symptoms, :string
    remove_column :appointments, :other_symptoms, :string
  end
end
