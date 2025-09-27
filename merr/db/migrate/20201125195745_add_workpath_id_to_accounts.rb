# typed: false
class AddWorkpathIdToAccounts < ActiveRecord::Migration[6.0]
  def change
    %i[field_admins field_dispatchers field_providers medarrive_admins].each do |table|
      add_column table, :workpath_id, :integer, index: true
    end
  end
end
