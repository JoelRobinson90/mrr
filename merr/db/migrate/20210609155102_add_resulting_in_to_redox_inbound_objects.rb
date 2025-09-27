class AddResultingInToRedoxInboundObjects < ActiveRecord::Migration[6.1]
  def change
    add_reference :redox_inbound_requests, :resulting_in, polymorphic: true
    add_column :redox_inbound_requests, :resulting_errors, :string
  end
end
