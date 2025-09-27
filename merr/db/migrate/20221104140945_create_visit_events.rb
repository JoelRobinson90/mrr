# frozen_string_literal: true

class CreateVisitEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :visit_events do |t|
      t.datetime :time, null: false
      t.string :location
      t.string :event_type
      t.references :field_provider, null: false, foreign_key: true
      t.references :visit, null: false, foreign_key: true

      t.timestamps
    end
  end
end
