# typed: true
class CreateIcd10Codes < ActiveRecord::Migration[6.0]
  def change
    create_table :icd10_codes do |t|
      t.string :code, index: { unique: true }
      t.string :description

      t.timestamps
    end
  end
end
