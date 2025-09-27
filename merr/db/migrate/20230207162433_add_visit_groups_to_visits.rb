# frozen_string_literal: true

class AddVisitGroupsToVisits < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :visit_group_id, :integer
  end
end
