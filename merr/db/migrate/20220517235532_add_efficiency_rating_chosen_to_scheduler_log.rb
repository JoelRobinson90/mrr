# frozen_string_literal: true

class AddEfficiencyRatingChosenToSchedulerLog < ActiveRecord::Migration[6.1]
  def change
    add_column :scheduler_logs, :rank_category_chosen, :string
  end
end
