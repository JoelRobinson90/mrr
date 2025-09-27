# frozen_string_literal: true

# typed: false
class CreateNewServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :alayacare_id, null: false

      t.timestamps
    end
  end
end
