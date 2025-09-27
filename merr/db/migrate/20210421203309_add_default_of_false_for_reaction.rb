# typed: false
class AddDefaultOfFalseForReaction < ActiveRecord::Migration[6.1]
  def change
    change_column :covid_vaccinations, :reaction, :boolean, default: false, null: false
  end
end
