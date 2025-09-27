# typed: false
class AddCohortToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :cohort_id, :integer
  end
end
