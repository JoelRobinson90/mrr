# frozen_string_literal: true

class CreatePatientPrograms < ActiveRecord::Migration[6.1]
  def change
    create_table :patient_programs do |t|
      t.references :patient, index: false
      t.references :program, index: false
      t.timestamps

      t.index %i[patient_id program_id]
      t.index %i[program_id patient_id]
    end
  end
end
