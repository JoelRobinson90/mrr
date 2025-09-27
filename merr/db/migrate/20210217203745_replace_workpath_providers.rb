# typed: false
# frozen_string_literal: true

class ReplaceWorkpathProviders < ActiveRecord::Migration[6.0]
  def change
    rename_column :appointments, :remote_provider_id, :field_provider_id
    remove_column :appointments, :mobile_provider_id, :integer
  end
end
