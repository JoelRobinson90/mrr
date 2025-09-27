class DropVisitOptimizerSettings < ActiveRecord::Migration[6.1]
  def change
    drop_table :visit_optimizer_settings do |t|
      t.integer :minutes_of_buffer_time, null: false
      t.integer :max_results, null: false
      t.integer :hours_before_first_option, null: false
      t.references :demand_partner, null: false, foreign_key: true
      t.boolean :create_local_visit, default: false
      t.integer :max_straight_line_distance_in_miles, null: false, default: 300

      t.timestamps
    end
  end
end
