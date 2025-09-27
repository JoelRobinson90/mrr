class CreateAthenaCustomFields < ActiveRecord::Migration[6.1]
  def change
    create_table :athena_custom_fields do |t|
      t.string :name
      t.integer :athena_id
      t.string :category

      t.timestamps
    end
  end
end
