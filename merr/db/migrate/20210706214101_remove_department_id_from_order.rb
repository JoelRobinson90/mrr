class RemoveDepartmentIdFromOrder < ActiveRecord::Migration[6.1]
  def change
    remove_column :orders, :department_id, :string
  end
end
