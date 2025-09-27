# typed: true
class CreateFacilities < ActiveRecord::Migration[6.0]
  def change
    create_table :facilities do |t|
      t.string :name
      t.belongs_to :demand_partner, null: false, foreign_key: true
      t.timestamps
    end
  end
end
