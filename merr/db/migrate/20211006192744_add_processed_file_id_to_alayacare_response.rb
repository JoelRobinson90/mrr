# frozen_string_literal: true

class AddProcessedFileIdToAlayacareResponse < ActiveRecord::Migration[6.1]
  def change
    add_column :alayacare_form_responses, :processed_file_id, :bigint
  end
end
