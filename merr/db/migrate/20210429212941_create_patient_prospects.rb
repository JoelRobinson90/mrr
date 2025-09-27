# typed: false
class CreatePatientProspects < ActiveRecord::Migration[6.1]
  def change
    create_table :patient_prospects do |t|
      t.string :medical_record_number
      t.references :demand_partner
      t.string :zipcode
      t.date :discharge_start
      t.date :discharge_end
      t.string :diagnosis
      t.string :preferred_language
      t.string :notes

      t.timestamps
    end
  end
end
