class AddRankCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :high_rank_percentile_threshold, :integer, default: 90
    add_column :programs, :medium_rank_percentile_threshold, :integer, default: 60
    add_column :programs, :high_rank_absolute_threshold, :integer, default: 90
    add_column :programs, :medium_rank_absolute_threshold, :integer, default: 60

    add_column :scheduler_logs, :high_rank_percentile_threshold, :integer
    add_column :scheduler_logs, :medium_rank_percentile_threshold, :integer
    add_column :scheduler_logs, :high_rank_absolute_threshold, :integer
    add_column :scheduler_logs, :medium_rank_absolute_threshold, :integer
  end
end