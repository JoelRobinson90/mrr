# frozen_string_literal: true

class AddWheniworkIdToFieldProvider < ActiveRecord::Migration[6.1]
  def change
    add_column :field_providers, :wheniwork_id, :string
  end
end
