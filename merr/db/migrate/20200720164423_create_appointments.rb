# typed: true
class CreateAppointments < ActiveRecord::Migration[6.0]
  def change
    create_table :appointments do |t|
      t.string :status, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.datetime :published_at
      t.references :mobile_provider, foreign_key: { to_table: 'providers' }
      t.references :remote_provider, foreign_key: { to_table: 'providers' }
      t.references :client, foreign_key: true
      t.string :medical_reference_number
      t.string :reason

      t.timestamps
    end
  end
end
