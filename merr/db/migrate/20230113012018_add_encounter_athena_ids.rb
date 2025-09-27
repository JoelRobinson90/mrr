class AddEncounterAthenaIds < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :athena_encounter_id, :integer
  end
end
