# frozen_string_literal: true

class AddRegionToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :region, :string
  end
end
