# frozen_string_literal: true

class AddMaxStraightLineDistanceInMilesToVisitOptimizerSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :visit_optimizer_settings, :max_straight_line_distance_in_miles, :int, null: false, default: 300
  end
end
