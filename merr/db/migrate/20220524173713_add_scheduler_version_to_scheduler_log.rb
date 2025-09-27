class AddSchedulerVersionToSchedulerLog < ActiveRecord::Migration[6.1]
  def change
    add_column :scheduler_logs, :scheduler_version, :integer, default: 1
  end
end
