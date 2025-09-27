# frozen_string_literal: true

class CreateAthenaDepartments < ActiveRecord::Migration[6.1]
  def change
    create_table :athena_departments do |t|
      t.string :name, null: false
      t.string :timezone, null: false
      t.string :generic_timezone, null: false
      t.integer :athena_id, null: false
      t.references :demand_partner, null: false, foreign_key: true

      t.timestamps
    end

    remove_column :demand_partners, :athena_id, :integer
    remove_column :demand_partners, :timezone, :string

    # Allow deploying migration without a manual sync step.
    Athena::PullExternalData.call(AthenaDepartment, "departments")
  end
end
