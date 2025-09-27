# typed: false
class CreateExtraVaccineRecipients < ActiveRecord::Migration[6.1]
  def change
    create_table :extra_vaccine_recipients do |t|
      t.string :name
      t.date :date_of_birth
      t.string :phone_number
      t.boolean :consent_to_text, default: false
      t.boolean :confirmed, default: false
      t.boolean :complete, default: false
      t.references :appointment, null: false, foreign_key: true, on_delete: :cascade

      t.timestamps
    end
  end
end
