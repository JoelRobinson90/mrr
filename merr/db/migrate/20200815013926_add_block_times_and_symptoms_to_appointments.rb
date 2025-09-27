# typed: false
class AddBlockTimesAndSymptomsToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :block_start_time, :datetime
    add_column :appointments, :block_end_time, :datetime
    add_column :appointments, :symptoms, :string, array: true, default: []
    add_column :appointments, :other_symptoms, :string
  end
end
