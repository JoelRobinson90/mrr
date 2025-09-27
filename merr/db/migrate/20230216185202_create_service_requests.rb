class CreateServiceRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :service_requests do |t|
      t.string :ma_id, null: false
      t.references :patient, null: false, foreign_key: true, index: false
      t.references :program, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.string :status, null: false, default: "requested"
      t.string :status_detail

      t.index :ma_id
      t.index [ :patient_id, :program_id, :service_id ], name: "patient_program_service_request_index"

      t.timestamps
    end

    create_sequence :service_request_ma_id
  end
end
