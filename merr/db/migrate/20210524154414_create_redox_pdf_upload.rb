# typed: false
class CreateRedoxPdfUpload < ActiveRecord::Migration[6.1]
  def change
    create_table :redox_pdf_uploads do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true

      t.string :filename, null: false
      t.string :redox_receipt
    end
  end
end
