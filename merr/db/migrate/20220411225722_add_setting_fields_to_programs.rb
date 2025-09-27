# frozen_string_literal: true

class AddSettingFieldsToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :minutes_of_buffer_time, :integer, null: false, default: 15
    add_column :programs, :max_results, :integer, null: false, default: 100
    add_column :programs, :hours_before_first_option, :integer, null: false, default: 10
    add_column :programs, :max_straight_line_distance_in_miles, :integer, null: false, default: 300
    add_column :programs, :drive_weight, :integer, null: false, default: 80
    add_column :programs, :proximity_weight, :integer, null: false, default: 10
    add_column :programs, :utilization_weight, :integer, null: false, default: 10
  end
end
