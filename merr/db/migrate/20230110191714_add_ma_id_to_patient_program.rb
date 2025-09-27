class AddMaIdToPatientProgram < ActiveRecord::Migration[6.1]
  def up
    add_column :patient_programs, :ma_id, :string

    add_index :patient_programs, :ma_id

    create_sequence :patient_program_ma_id
  end

  def down
    remove_column :patient_programs, :ma_id

    drop_sequence :patient_program_ma_id
  end
end
