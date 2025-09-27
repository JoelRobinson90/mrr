# typed: false
class AddDepartmentIdToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :department_id, :string
  end
end
