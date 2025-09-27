class RemoveDepartmentIdFromRedoxDestinations < ActiveRecord::Migration[6.1]
  def change
    remove_column :redox_destinations, :department, :string
  end
end
