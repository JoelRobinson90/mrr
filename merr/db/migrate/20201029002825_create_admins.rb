# typed: true
class CreateAdmins < ActiveRecord::Migration[6.0]
  def change
    create_table :field_admins do |t|
      t.string :first_name
      t.string :last_name
      t.references :field_org, null: false, foreign_key: true

      t.timestamps
    end

    create_table :field_dispatchers do |t|
      t.string :first_name
      t.string :last_name
      t.references :field_org, null: false, foreign_key: true

      t.timestamps
    end

    create_table :medarrive_admins do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
