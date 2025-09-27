# typed: true
class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :insurance_company
      t.string :insurance_type
      t.string :insurance_member_number
      t.string :insurance_group_number
      t.references :client, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
