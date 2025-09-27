# typed: false
class AddSplitCounterAndRegionalToCohort < ActiveRecord::Migration[6.1]
  def change
    add_column :cohorts, :split_counter, :integer, default: 0
    add_column :cohorts, :regional, :boolean, default: true
  end
end
