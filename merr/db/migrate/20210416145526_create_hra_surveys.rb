# typed: false
class CreateHraSurveys < ActiveRecord::Migration[6.1]
  def change
    create_table :hra_surveys do |t|
      t.jsonb :survey
      t.references :patient, null: false, foreign_key: true

      t.timestamps
    end
  end
end
