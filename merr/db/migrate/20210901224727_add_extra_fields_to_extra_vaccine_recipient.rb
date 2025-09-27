class AddExtraFieldsToExtraVaccineRecipient < ActiveRecord::Migration[6.1]
  def change
    add_column :extra_vaccine_recipients, :race, :string
    add_column :extra_vaccine_recipients, :ethnicity, :string
    add_column :extra_vaccine_recipients, :unable_to_vaccinate, :string
    add_column :extra_vaccine_recipients, :unable_to_vaccinate_reason, :string
    add_reference :extra_vaccine_recipients, :covid_vaccination, null: true, foreign_key: true
  end
end
