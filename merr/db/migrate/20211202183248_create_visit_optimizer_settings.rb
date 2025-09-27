# frozen_string_literal: true

class CreateVisitOptimizerSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :visit_optimizer_settings do |t|
      t.integer :minutes_of_buffer_time, null: false
      t.integer :max_results, null: false
      t.integer :hours_before_first_option, null: false

      t.timestamps
    end
  end
end
