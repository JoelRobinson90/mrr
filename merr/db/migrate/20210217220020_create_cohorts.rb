# typed: true
class CreateCohorts < ActiveRecord::Migration[6.0]
  def change
    create_table :cohorts do |t|
      t.string :name
      t.references :demand_partner, null: false, foreign_key: {on_delete: :cascade}
      t.integer :service_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :block_size
      t.integer :vaccines_per_block
      t.integer :total_vaccines
      t.string :status

      t.timestamps
    end
  end
end
