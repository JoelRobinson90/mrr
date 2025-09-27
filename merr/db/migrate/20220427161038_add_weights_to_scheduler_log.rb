class AddWeightsToSchedulerLog < ActiveRecord::Migration[6.1]
  def change
    add_column :scheduler_logs, :drive_weight, :integer
    add_column :scheduler_logs, :proximity_weight, :integer
    add_column :scheduler_logs, :utilization_weight, :integer
  end
end
