# frozen_string_literal: true

class CreateVisitTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :visit_types do |t|
      t.string :name, null: false
      t.integer :duration, null: false
      t.string :alayacare_id, null: false
      t.references :program, null: true, foreign_key: true

      t.timestamps
    end

    add_reference :visits, :visit_type, null: false, foreign_key: true
  end
end
