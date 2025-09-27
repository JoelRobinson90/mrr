class AddPlusOnesEnabledToVisitType < ActiveRecord::Migration[6.1]
  def change
    add_column :visit_types, :plus_ones_enabled, :boolean
  end
end
