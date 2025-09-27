# frozen_string_literal: true

class AddDuplicatestoRedoxInboundRequest < ActiveRecord::Migration[6.1]
  def change
    add_column :redox_inbound_requests, :duplicate_of_id, :integer, nil: true
    add_index :redox_inbound_requests, :duplicate_of_id
  end
end
