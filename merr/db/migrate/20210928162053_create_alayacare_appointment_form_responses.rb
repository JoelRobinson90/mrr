class CreateAlayacareAppointmentFormResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :alayacare_form_responses do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true
      t.string :alayacare_form_identifier
      t.string :alayacare_client_identifier
      t.string :alayacare_client_form_identifier
      t.string :alayacare_service_identifier

      t.timestamps
    end
  end
end
