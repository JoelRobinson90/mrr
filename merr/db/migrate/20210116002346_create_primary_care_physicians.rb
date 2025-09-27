# typed: true
class CreatePrimaryCarePhysicians < ActiveRecord::Migration[6.0]
  def change
    create_table :primary_care_physicians do |t|
      t.string :name, null: false
      t.string :office_name
      t.string :office_phone_number

      t.timestamps
    end

    add_reference :patients, :primary_care_physician, null: true, foreign_key: true
  end
end
