# typed: false
class AddCountyToAddress < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :county, :string
  end
end
