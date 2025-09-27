# frozen_string_literal: true

class CreateBackgroundJobResults < ActiveRecord::Migration[6.1]
  def change
    create_table :background_job_results do |t|
      t.string :status, null: false
      t.string :job_type, null: false
      t.string :label
      t.string :message
      t.string :error_list, array: true, default: []

      t.timestamps
    end
  end
end
