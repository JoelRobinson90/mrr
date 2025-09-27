class AddFormTemplateProcessorUsedToAlayacareProcessedFile < ActiveRecord::Migration[6.1]
  def change
    add_column :alayacare_processed_files, :form_template, :string
  end
end
