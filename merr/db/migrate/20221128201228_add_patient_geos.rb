class AddPatientGeos < ActiveRecord::Migration[6.1]
  def change
    create_table :service_areas do |t|
      t.string :name

      t.timestamps
    end

    create_table :geo_cohorts do |t|
      t.string :name
      t.references :service_area, null: false, foreign_key: true

      t.timestamps
    end

    create_table :patient_geos do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :program, null: false, foreign_key: true
      t.references :geo_cohort, null: false, foreign_key: true
      t.references :service_area, null: false, foreign_key: true

      t.timestamps
    end
    add_index :patient_geos, [:patient_id, :program_id], unique: true

    add_column :programs, :enforce_service_area, :boolean, default: false
    add_column :scheduler_logs, :enforce_service_area, :boolean, default: false
    add_reference :scheduler_logs, :service_area, null: true, foreign_key: true
  end
end
