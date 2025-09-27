# typed: true
class CreateInsurances < ActiveRecord::Migration[6.0]
  def change
    create_table :insurances do |t|
      t.string :member_id, null: false
      t.string :plan_id, null: false
      t.string :group_id, null: false

      t.text :plan_description
      t.string :bin_number
      t.date :effective_date
      t.date :renewal_date

      t.references :patient, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
