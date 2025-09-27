class AddDeletedAtToCohorts < ActiveRecord::Migration[6.1]
  def change
    add_column :cohorts, :deleted_at, :datetime
    add_index :cohorts, :deleted_at
  end
end
