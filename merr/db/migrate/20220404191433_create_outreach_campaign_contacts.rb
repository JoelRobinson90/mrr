class CreateOutreachCampaignContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :outreach_campaign_contacts do |t|
      t.string :kustomer_customer_id, null: false
      t.string :status, null: false, index: true, default: "created"
      t.string :kustomer_conversation_id
      t.references :outreach_campaign, null: false, foreign_key: true

      t.timestamps
    end

    add_index :outreach_campaign_contacts, [:outreach_campaign_id, :kustomer_customer_id], unique: true, name: 'index_outreach_campaign_contacts_on_campaign_id_and_customer_id'
  end
end
