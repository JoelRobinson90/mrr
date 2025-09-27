class AddAthenaIds < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :athena_id, :integer
    add_column :field_providers, :athena_id, :integer
    add_column :visits, :athena_id, :integer
    add_column :visit_types, :athena_id, :integer
  end
end
