# typed: false
class CreateRedoxPatientIdentifiers < ActiveRecord::Migration[6.1]
  def change
    create_table :redox_patient_identifiers do |t|
      t.string :id_type, null: false
      t.references :patient, null: false, foreign_key: true
      t.string :identifier, null: false

      t.timestamps
    end
  end
end
