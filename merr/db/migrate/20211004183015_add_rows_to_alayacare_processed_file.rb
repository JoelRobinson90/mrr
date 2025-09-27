# frozen_string_literal: true

class AddRowsToAlayacareProcessedFile < ActiveRecord::Migration[6.1]
  def change
    add_column :alayacare_processed_files, :rows, :integer, default: 0, null: false
  end
end
