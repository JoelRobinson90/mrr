class AddVisitConfirmed < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :confirmed, :boolean
  end
end
