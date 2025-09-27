# typed: false
class RemoveNullRequirementsFromAppointments < ActiveRecord::Migration[6.0]
  def change
  	change_column_null :appointments, :start_time, true
  	change_column_null :appointments, :end_time, true
  end
end
