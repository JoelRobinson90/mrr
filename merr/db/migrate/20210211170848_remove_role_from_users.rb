# typed: false
class RemoveRoleFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :role, :string, null: false, default: 'None'
  end
end
