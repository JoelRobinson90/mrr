# typed: false
class MoveVaccineQuanityFromAppointmentToCovidVaccine < ActiveRecord::Migration[6.1]
  def change
    remove_column :appointments, :vaccine_quantity, :integer, default: 1, null: false
    add_column :covid_vaccinations, :vaccine_quantity, :integer, default: 1, null: false
  end
end
