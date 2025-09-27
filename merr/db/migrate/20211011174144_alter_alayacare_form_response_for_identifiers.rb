class AlterAlayacareFormResponseForIdentifiers < ActiveRecord::Migration[6.1]
  def change
    change_column :alayacare_form_responses, :patient_id, :bigint, null: true
    change_column :alayacare_form_responses, :appointment_id, :bigint, null: true

    add_column :alayacare_form_responses, :alayacare_patient_id, :string
    add_column :alayacare_form_responses, :alayacare_service_id, :string
  end
end
