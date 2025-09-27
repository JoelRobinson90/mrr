# typed: false
class AddDataModelToRedoxDestinations < ActiveRecord::Migration[6.1]
  def change
    add_column :redox_destinations, :data_model, :string
  end
end
