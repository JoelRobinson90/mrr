# typed: false
class CreateServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :description
      t.integer :estimated_duration, null: false, default: 0
      t.string :category, null: false

      t.timestamps
    end
  end
end
