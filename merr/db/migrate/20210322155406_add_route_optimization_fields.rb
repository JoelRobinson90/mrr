# typed: false
class AddRouteOptimizationFields < ActiveRecord::Migration[6.1]
  def change
    add_column :cohorts, :route_geojson, :text
    add_column :appointments, :route_index, :integer
  end
end
