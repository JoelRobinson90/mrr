# typed: false
class AddNewPatientSchemaFieldsToPatient < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :middle_initial, :string
    add_column :patients, :phone_number, :string
    add_column :patients, :secondary_phone_number, :string
    add_column :patients, :medical_record_number, :string
    add_column :patients, :emergency_contact_name, :string
    add_column :patients, :emergency_contact_phone_number, :string

    add_reference :patients, :provider_org, null: false, foreign_key: true

    add_column :patients, :patient_notes, :text
  end
end
