class AddOutreachVisitToVisitType < ActiveRecord::Migration[6.1]
  def change
    add_column :visit_types, :outreach_visit, :boolean, default: false
  end
end