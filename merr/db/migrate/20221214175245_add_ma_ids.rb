class AddMaIds < ActiveRecord::Migration[6.1]
  def up
    add_column :patients, :ma_id, :string
    add_column :visits, :ma_id, :string
    add_column :field_providers, :ma_id, :string
    add_column :demand_partners, :ma_id, :string
    add_column :programs, :ma_id, :string

    add_index :patients, :ma_id
    add_index :visits, :ma_id
    add_index :field_providers, :ma_id
    add_index :demand_partners, :ma_id
    add_index :programs, :ma_id
  end

  def down
    remove_column :patients, :ma_id
    remove_column :visits, :ma_id
    remove_column :field_providers, :ma_id
    remove_column :demand_partners, :ma_id
    remove_column :programs, :ma_id
  end
end
