# frozen_string_literal: true

class AddV2FlagAndStatus < ActiveRecord::Migration[6.1]
  def change
    add_column :programs, :v2, :boolean, default: false
    add_column :visits, :status, :string, default: "scheduled"
  end
end
