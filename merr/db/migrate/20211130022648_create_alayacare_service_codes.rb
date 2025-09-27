# frozen_string_literal: true

class CreateAlayacareServiceCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :alayacare_service_codes do |t|
      t.string :name
      t.integer :duration

      t.timestamps
    end
  end
end
