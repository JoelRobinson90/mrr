# typed: false
class AddLatLongToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :latitude, :string
    add_column :addresses, :longitude, :string
  end
end
