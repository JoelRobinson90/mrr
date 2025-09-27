# typed: false
class AddRaceAndEthnicityToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :race, :string
    add_column :patients, :ethnicity, :string
  end
end
