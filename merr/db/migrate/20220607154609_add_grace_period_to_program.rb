class AddGracePeriodToProgram < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :max_grace_period, :integer, default: 0

    add_column :scheduler_logs, :max_grace_period, :integer
    add_column :scheduler_logs, :grace_period_options_count, :integer
  end
end