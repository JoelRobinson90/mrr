class CreateSurveys < ActiveRecord::Migration[6.1]
  def change
    create_table :surveys do |t|
      t.string :name, null: false, index: true
      t.references :patient, null: false, foreign_key: true
      t.references :appointment, foreign_key: true
      t.jsonb :response, default: []
      t.datetime :responded_at

      t.timestamps
    end
  end
end
