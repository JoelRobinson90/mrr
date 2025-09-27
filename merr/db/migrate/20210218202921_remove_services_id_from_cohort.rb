# typed: false
class RemoveServicesIdFromCohort < ActiveRecord::Migration[6.0]
  def change
    remove_column :cohorts, :service_id, :integer
  end
end
