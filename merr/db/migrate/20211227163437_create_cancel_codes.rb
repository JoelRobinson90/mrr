class CreateCancelCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :cancel_codes do |t|
      t.integer :alayacare_id, null: false
      t.string :code, null: false
      t.string :description

      t.timestamps
    end
  end
end
