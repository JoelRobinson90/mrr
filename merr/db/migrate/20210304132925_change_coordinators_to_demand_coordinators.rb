# typed: false
class ChangeCoordinatorsToDemandCoordinators < ActiveRecord::Migration[6.0]
  def change
    rename_table :coordinators, :demand_coordinators
  end
end