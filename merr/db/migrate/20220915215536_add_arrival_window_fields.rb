class AddArrivalWindowFields < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :arrival_window_start, :datetime
    add_column :visits, :arrival_window_end, :datetime

    add_column :programs, :arrival_window_offset_minutes, :integer
    add_column :programs, :arrival_window_block_schedule, :string
  end
end
