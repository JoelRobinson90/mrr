class UpdateOutreachCampaignColumns < ActiveRecord::Migration[6.1]
  def up
    rename_column :outreach_campaigns, :rate_per_min, :rate_per_hour
    change_column_default :outreach_campaigns, :rate_per_hour, 60

    remove_column :outreach_campaign_contacts, :kustomer_conversation_id
    add_column :outreach_campaign_contacts, :kustomer_bulk_id, :string
  end

  def down
    rename_column :outreach_campaigns, :rate_per_hour, :rate_per_min
    change_column_default :outreach_campaigns, :rate_per_min, 1

    add_column :outreach_campaign_contacts, :kustomer_conversation_id, :string
    remove_column :outreach_campaign_contacts, :kustomer_bulk_id
  end
end
