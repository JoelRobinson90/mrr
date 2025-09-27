# frozen_string_literal: true

class AddDefaultDurationToVisitType < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:visit_types, :duration, 0)
  end
end
