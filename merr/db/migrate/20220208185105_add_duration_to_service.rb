# frozen_string_literal: true

class AddDurationToService < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :duration, :integer, null: false, default: -> { 0 }
  end
end
