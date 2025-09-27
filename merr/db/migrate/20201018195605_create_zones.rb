# typed: true
class CreateZones < ActiveRecord::Migration[6.0]
  def change
    create_table :zones do |t|
      t.string :name, null: false
      t.references :provider_organization, null: false, foreign_key: true
      t.integer :workpath_id, null: false

      t.timestamps
    end
  end
end
