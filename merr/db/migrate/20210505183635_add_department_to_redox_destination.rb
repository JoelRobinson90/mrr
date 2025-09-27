# typed: false
class AddDepartmentToRedoxDestination < ActiveRecord::Migration[6.1]
  def change
    add_column :redox_destinations, :department, :string
  end
end
