# typed: true
class AddPatientsToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_reference :appointments, :patient, null: true, foreign_key: true
  end
end
