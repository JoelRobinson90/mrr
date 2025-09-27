# typed: true
class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.string :address_line_one
      t.string :address_line_two
      t.string :city
      t.string :state
      t.string :zipcode
      t.references :client, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
