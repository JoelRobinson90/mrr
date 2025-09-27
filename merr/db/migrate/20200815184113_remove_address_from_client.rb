# typed: false
class RemoveAddressFromClient < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :clients, :address_line_one
    remove_column :clients, :address_line_two
    remove_column :clients, :city
    remove_column :clients, :state
    remove_column :clients, :zipcode
  end

  def self.down
    add_column :clients, :address_line_one, :string
    add_column :clients, :address_line_two, :string
    add_column :clients, :city, :string
    add_column :clients, :state, :string
    add_column :clients, :zipcode, :string
  end
end
