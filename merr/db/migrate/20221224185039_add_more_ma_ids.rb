class AddMoreMaIds < ActiveRecord::Migration[6.1]
  def up
    add_column :field_orgs, :ma_id, :string
    add_column :cancel_codes, :ma_id, :string
    add_column :visit_types, :ma_id, :string

    add_index :field_orgs, :ma_id
    add_index :cancel_codes, :ma_id
    add_index :visit_types, :ma_id

    create_sequence :field_org_ma_id
    create_sequence :cancel_code_ma_id
    create_sequence :visit_type_ma_id
  end

  def down
    remove_column :field_orgs, :ma_id
    remove_column :cancel_codes, :ma_id
    remove_column :visit_types, :ma_id

    drop_sequence :field_org_ma_id
    drop_sequence :cancel_code_ma_id
    drop_sequence :visit_type_ma_id
  end
end
