# typed: false
class DisambiguationOfRedoxTargets < ActiveRecord::Migration[6.0]
  def change
    rename_column :redox_destinations, :redox_provider_id, :redox_destination_id
  end
end
