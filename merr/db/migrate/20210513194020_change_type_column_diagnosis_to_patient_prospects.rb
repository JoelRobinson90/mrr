# typed: false
class ChangeTypeColumnDiagnosisToPatientProspects < ActiveRecord::Migration[6.1]
  def change
    change_column :patient_prospects, :diagnosis, "varchar[] USING (string_to_array(diagnosis, ','))"
  end
end
