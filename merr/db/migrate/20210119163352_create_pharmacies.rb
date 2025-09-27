# typed: true
class CreatePharmacies < ActiveRecord::Migration[6.0]
  def change
    create_table :pharmacies do |t|
      t.string :name, null: false
      t.string :phone_number
      t.references :patient, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
