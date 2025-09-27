class CreateWorkSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :work_sessions do |t|
      t.datetime :clock_in, null: false
      t.datetime :clock_out
      t.string :clock_in_location
      t.string :clock_out_location
      t.references :field_provider, null: false, foreign_key: true
      t.references :visit, null: false, foreign_key: true

      t.timestamps
    end
  end
end
