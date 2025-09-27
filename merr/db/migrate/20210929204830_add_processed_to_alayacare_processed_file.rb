class AddProcessedToAlayacareProcessedFile < ActiveRecord::Migration[6.1]
  def change
    add_column :alayacare_processed_files, :processed, :bool
  end
end
