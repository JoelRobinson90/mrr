# frozen_string_literal: true

class AddErrorLoggingFields < ActiveRecord::Migration[6.1]
  def change
    add_column :visits, :push_to_athena_error, :string
    add_column :visits, :push_to_alayacare_error, :string

    add_column :field_providers, :push_to_wheniwork_error, :string
  end
end
