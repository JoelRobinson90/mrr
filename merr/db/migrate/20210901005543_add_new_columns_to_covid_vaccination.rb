class AddNewColumnsToCovidVaccination < ActiveRecord::Migration[6.1]
  def change
    add_column :covid_vaccinations, :lot, :string
    add_column :covid_vaccinations, :route, :string
    add_column :covid_vaccinations, :site, :string
    add_column :covid_vaccinations, :dose, :string
    add_column :covid_vaccinations, :expire, :datetime
  end
end
