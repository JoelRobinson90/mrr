# frozen_string_literal: true

class CreateOutreachCampaigns < ActiveRecord::Migration[6.1]
  def change
    create_table :outreach_campaigns do |t|
      t.string :name, null: false
      t.integer :rate_per_min, null: false, default: 1
      t.string :kustomer_tag_id, null: false
      t.string :kustomer_search_id, null: false
      t.json :kustomer_conversation_fields, null: false, default: {}
      t.boolean :active, null: false, default: false

      t.timestamps
    end
  end
end
