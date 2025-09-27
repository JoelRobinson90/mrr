class AddDriveTimeBreakpointsToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :drive_time_breakpoints, :string
    add_column :scheduler_logs, :drive_time_breakpoints, :string
  end
end
