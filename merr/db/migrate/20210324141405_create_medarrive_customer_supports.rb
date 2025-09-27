# typed: false
class CreateMedarriveCustomerSupports < ActiveRecord::Migration[6.1]
  def change
    create_table :medarrive_customer_supports do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number

      t.timestamps
    end
  end
end
