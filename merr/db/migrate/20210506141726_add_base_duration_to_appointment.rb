# typed: false
class AddBaseDurationToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :base_duration, :integer, default: 30
  end
end
