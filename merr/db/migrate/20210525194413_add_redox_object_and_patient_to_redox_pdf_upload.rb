# typed: false
class AddRedoxObjectAndPatientToRedoxPdfUpload < ActiveRecord::Migration[6.1]
  def change
    remove_column :redox_pdf_uploads, :user_id, :integer

    change_table :redox_pdf_uploads do |t|
      t.references :patient, null: false, foreign_key: true
      t.json :redox_object
    end
  end
end