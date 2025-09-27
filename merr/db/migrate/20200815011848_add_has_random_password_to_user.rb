# typed: false
class AddHasRandomPasswordToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :has_random_password, :boolean, default: false
  end
end
