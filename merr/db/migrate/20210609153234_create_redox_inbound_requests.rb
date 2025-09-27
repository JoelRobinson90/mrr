class CreateRedoxInboundRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :redox_inbound_requests do |t|
      t.json :body
      t.boolean :processed, default: false, null: false

      t.timestamps
    end
  end
end
