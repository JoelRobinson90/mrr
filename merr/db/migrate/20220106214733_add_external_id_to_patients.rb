# frozen_string_literal: true

class AddExternalIdToPatients < ActiveRecord::Migration[6.1]
  def up
    # pre-index to speed up migration
    add_column :patients, :external_id, :string
    add_index :patients, :external_id

    # Generate external_ids for all patients
    Patient.find_each(batch_size: 1000) do |patient|
      patient.generate_external_id

      # skip sending to Alayacare
      patient.update_columns(external_id: patient.external_id)
    end

    # make index unique, and prevent nulls
    remove_index :patients, :external_id, if_exists: true
    add_index :patients, :external_id, unique: true
    change_column_null :patients, :external_id, false
  end

  def down
    remove_column :patients, :external_id
  end
end
