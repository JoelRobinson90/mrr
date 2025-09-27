# frozen_string_literal: true

class CreatePrograms < ActiveRecord::Migration[6.1]
  def change
    create_table :programs do |t|
      t.string :name, null: false
      t.string :alayacare_service_code_id, null: false
      t.references :demand_partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
