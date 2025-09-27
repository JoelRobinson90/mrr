# frozen_string_literal: true

class CreateVisitRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :visit_requests do |t|
      t.references :program, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: {to_table: :users}
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
