# frozen_string_literal: true

class CreateKustomerCsvUploadFailures < ActiveRecord::Migration[6.1]
  def change
    create_table :kustomer_csv_upload_failures do |t|
      t.binary :content
      t.references :kustomer_csv_upload, null: false, foreign_key: true
      t.string :error
      t.integer :csv_row_number
      t.string :patient_name

      t.timestamps
    end
  end
end
