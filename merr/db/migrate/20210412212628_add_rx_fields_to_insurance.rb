# typed: false
class AddRxFieldsToInsurance < ActiveRecord::Migration[6.1]
  def up
    add_column :insurances, :rx_pcn, :string
    add_column :insurances, :rx_group, :string
    add_column :insurances, :name, :string

    remove_column :insurances, :plan_id

    change_column_null :insurances, :group_id, true
    change_column_null :insurances, :member_id, true
  end

  def down
    remove_column :insurances, :rx_pcn
    remove_column :insurances, :rx_group
    remove_column :insurances, :name

    add_column :insurances, :plan_id, :string, null: false

    change_column_null :insurances, :group_id, false
    change_column_null :insurances, :member_id, false
  end
  
end
