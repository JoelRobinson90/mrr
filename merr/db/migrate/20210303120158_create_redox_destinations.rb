# typed: true
class CreateRedoxDestinations < ActiveRecord::Migration[6.0]
  def change
    create_table :redox_destinations do |t|
      t.string :redox_provider_id, null: false
      t.string :name, null: false
      t.references :demand_partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
