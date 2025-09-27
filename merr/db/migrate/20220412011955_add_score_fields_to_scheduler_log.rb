# frozen_string_literal: true

class AddScoreFieldsToSchedulerLog < ActiveRecord::Migration[6.1]
  def change
    add_column :scheduler_logs, :total_score, :integer
    add_column :scheduler_logs, :drive_score, :integer
    add_column :scheduler_logs, :proximity_score, :integer
    add_column :scheduler_logs, :utilization_score, :integer

    add_reference :scheduler_logs, :visit, null: true, foreign_key: true
  end
end
