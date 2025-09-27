# typed: false
class AddDeletedToExtraVaccineRecipients < ActiveRecord::Migration[6.1]
  def change
    add_column :extra_vaccine_recipients, :deleted, :boolean, default: false
  end
end
