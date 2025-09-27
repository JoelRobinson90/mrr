class DropIcd10Table < ActiveRecord::Migration[6.1]
  def change
    drop_table :icd10_codes do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
