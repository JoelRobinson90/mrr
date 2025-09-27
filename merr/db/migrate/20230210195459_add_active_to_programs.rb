# frozen_string_literal: true

class AddActiveToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :active, :boolean, default: true
  end
end
