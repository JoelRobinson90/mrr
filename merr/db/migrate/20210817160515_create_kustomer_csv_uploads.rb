# frozen_string_literal: true

class CreateKustomerCsvUploads < ActiveRecord::Migration[6.1]
  def change
    create_table :kustomer_csv_uploads do |t|
      t.binary :content
      t.references :user, null: false, foreign_key: true
      t.references :demand_partner, null: false, foreign_key: true
      t.string :csv_name, null: false
      t.integer :total_rows, null: false
      t.integer :total_success
      t.integer :total_fails

      t.timestamps
    end
  end
end
