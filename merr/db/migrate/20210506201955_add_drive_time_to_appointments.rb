# typed: false
class AddDriveTimeToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :drive_time, :float
  end
end
