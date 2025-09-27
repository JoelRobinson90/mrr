# typed: false
class AddTimezoneToAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :timezone, :string
  end
end
