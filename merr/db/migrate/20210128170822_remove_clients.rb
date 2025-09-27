# typed: false
class RemoveClients < ActiveRecord::Migration[6.0]
  def change
    remove_reference :appointments, :client, foreign_key: true
    drop_table :clients do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :stripe_token
      t.timestamps
    end
  end
end
