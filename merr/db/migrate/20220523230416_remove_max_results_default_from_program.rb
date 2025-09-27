class RemoveMaxResultsDefaultFromProgram < ActiveRecord::Migration[6.1]
  def up
    change_column_null(:programs, :max_results, true)
    change_column_default(:programs, :max_results, nil)
  end

  def down
    change_column_default(:programs, :max_results, 100)
    change_column_null(:programs, :max_results, false)
  end
end
