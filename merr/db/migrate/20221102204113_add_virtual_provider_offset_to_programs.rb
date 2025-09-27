# frozen_string_literal: true

class AddVirtualProviderOffsetToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :virtual_provider_offset, :integer
    add_column :scheduler_logs, :virtual_provider_offset, :integer
  end
end
