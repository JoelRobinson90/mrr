# typed: false
class RemoveZones < ActiveRecord::Migration[6.0]
  def up
  	drop_table :zones do |t|
      t.string :name, null: false
      t.references :field_org, null: false, foreign_key: true
      t.integer :workpath_id, null: false

      t.timestamps
    end

    add_column :field_orgs, :workpath_id, :integer
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
