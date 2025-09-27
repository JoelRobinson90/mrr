# frozen_string_literal: true

class RemoveWhenIWorkIdFromFieldProviders < ActiveRecord::Migration[6.1]
  def change
    remove_column :field_providers, :wheniwork_id, :string
  end
end
