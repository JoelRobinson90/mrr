# typed: false
# frozen_string_literal: true

class RemoveWorkpathReferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :field_admins, :workpath_id, :integer
    remove_column :field_dispatchers, :workpath_id, :integer
    remove_column :field_orgs, :workpath_id, :integer
    remove_column :field_providers, :workpath_id, :integer
    remove_column :medarrive_admins, :workpath_id, :integer
  end
end
