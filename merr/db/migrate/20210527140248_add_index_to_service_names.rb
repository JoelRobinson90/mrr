# typed: false
class AddIndexToServiceNames < ActiveRecord::Migration[6.1]
  def change
    add_index :services, :name
  end
end
