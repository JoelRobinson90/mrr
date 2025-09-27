# typed: false
class CreateAvailabilitySlots < ActiveRecord::Migration[6.1]
  def change
    create_table :availability_slots do |t|
      t.string :day_of_week, null: false
      t.integer :start_hour, null: false
      t.integer :end_hour, null: false

      t.timestamps
    end
  end
end
