class AddShortenWeight < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :shift_shortening_penalty_weight, :integer, default: 0
    add_column :scheduler_logs, :shift_shortening_penalty_score, :integer, default: 0
    add_column :scheduler_logs, :shift_shortening_penalty_weight, :integer, default: 0
  end
end
