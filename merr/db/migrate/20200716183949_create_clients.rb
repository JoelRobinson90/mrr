# typed: true
class CreateClients < ActiveRecord::Migration[6.0]
  def change
    create_table :clients do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :address_line_one
      t.string :address_line_two
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :stripe_token
      t.references :user, foreign_key: {on_delete: :cascade}, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
