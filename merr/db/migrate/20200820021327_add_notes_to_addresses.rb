# typed: false
class AddNotesToAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :notes, :string
  end
end
