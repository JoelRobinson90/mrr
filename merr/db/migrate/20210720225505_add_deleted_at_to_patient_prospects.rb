class AddDeletedAtToPatientProspects < ActiveRecord::Migration[6.1]
  def change
    add_column :patient_prospects, :deleted_at, :datetime
    add_index :patient_prospects, :deleted_at
  end
end
