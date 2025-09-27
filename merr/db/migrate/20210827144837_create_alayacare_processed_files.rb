# frozen_string_literal: true

class CreateAlayacareProcessedFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :alayacare_processed_files do |t|
      t.datetime :processed_on, null: false
      t.boolean :errored, default: false, null: false
      t.string :filename, null: false
      t.text :error_messages, null: true

      t.timestamps
    end
  end
end
