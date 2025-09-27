class CreateUploadedDataImports < ActiveRecord::Migration[6.1]
  def change
    create_table :uploaded_data_imports do |t|
      t.binary :content
      t.boolean :processed, null: false, default: false
      t.references :user, null: false, foreign_key: true
      t.string :content_type, null: false
      t.references :demand_partner, null: false, foreign_key: true
      t.string :operation_type, null: false

      t.timestamps
    end
  end
end
