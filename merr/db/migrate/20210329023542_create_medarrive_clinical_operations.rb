# typed: false
class CreateMedarriveClinicalOperations < ActiveRecord::Migration[6.1]
  def change
    create_table :medarrive_clinical_operations do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number

      t.timestamps
    end
  end
end
