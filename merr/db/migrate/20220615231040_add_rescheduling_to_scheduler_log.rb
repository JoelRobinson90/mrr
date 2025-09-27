class AddReschedulingToSchedulerLog < ActiveRecord::Migration[6.1]
  def change
    add_column :scheduler_logs, :rescheduling, :boolean, default: false
  end
end
