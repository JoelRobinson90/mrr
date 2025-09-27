# typed: false
class CreateCovidVaccinations < ActiveRecord::Migration[6.1]
  def change
    create_table :covid_vaccinations do |t|
      t.string :vaccine_type
      t.boolean :reaction
      t.text :reaction_notes
      t.references :appointment, null: false, foreign_key: true, on_delete: :cascade

      t.timestamps
    end
  end
end
