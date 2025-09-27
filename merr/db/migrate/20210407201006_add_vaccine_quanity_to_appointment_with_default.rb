# typed: false
class AddVaccineQuanityToAppointmentWithDefault < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :vaccine_quantity, :integer, default: 1, null: false
  end
end
