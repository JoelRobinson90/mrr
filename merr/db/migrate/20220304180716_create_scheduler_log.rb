# frozen_string_literal: true

class CreateSchedulerLog < ActiveRecord::Migration[6.1]
  def change
    create_table :scheduler_logs do |t|
      t.string :run_id, null: false
      t.datetime :request_time
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :visit_location
      t.date :start_date
      t.date :end_date
      t.integer :buffer_time
      t.integer :max_results
      t.integer :hours_before_first_option
      t.integer :max_distance
      t.integer :elapsed_time_for_results
      t.integer :existing_visits_count
      t.string :existing_visits_dump
      t.integer :blocked_shifts_count
      t.string :blocked_shifts_dump
      t.integer :no_location_shifts_count
      t.string :no_location_shifts_dump
      t.integer :shifts_count
      t.string :shifts_dump
      t.integer :initial_slots_count
      t.integer :valid_slots_count
      t.integer :options_blocked_by_no_location_visit
      t.integer :options_count
      t.string :options_dump
      t.float :days_until_soonest_option
      t.integer :best_drive_time
      t.integer :worst_drive_time
      t.boolean :visit_created, default: false
      t.boolean :blocked_for_race_condition
      t.string :visit_error_message
      t.float :elapsed_time_for_choice
      t.integer :picks_before_booking
      t.integer :index_chosen
      t.integer :drive_time_chosen
      t.datetime :start_time_chosen
      t.datetime :end_time_chosen
      t.string :field_provider_name

      t.timestamps
    end
  end
end
