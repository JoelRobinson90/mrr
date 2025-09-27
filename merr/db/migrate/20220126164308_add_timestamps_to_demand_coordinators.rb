# frozen_string_literal: true

class AddTimestampsToDemandCoordinators < ActiveRecord::Migration[6.1]
  def change
    add_timestamps :demand_coordinators, null: false, default: -> { "NOW()" }
  end
end
