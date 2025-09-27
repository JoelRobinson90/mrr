# frozen_string_literal: true

class CreateVisits < ActiveRecord::Migration[6.1]
  def change
    create_table :visits do |t|
      t.string :external_id, null: false
      t.references :patient, null: false, foreign_key: true
      t.references :field_provider, null: true, foreign_key: true
      t.references :program, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :service_instructions
      t.boolean :canceled, default: false
      t.references :cancel_code, null: true, foreign_key: true

      t.timestamps
    end
  end
end
