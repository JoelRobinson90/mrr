class DropPatientRedoxIdentifiers < ActiveRecord::Migration[6.1]
  def change
    drop_table :redox_patient_identifiers
  end
end
