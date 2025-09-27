# frozen_string_literal: true

class AddTimesToOutreachCampaign < ActiveRecord::Migration[6.1]
  def change    
    add_column :outreach_campaigns, :not_before_local_time, :time, null: false, default: "09:00"
    add_column :outreach_campaigns, :not_after_local_time, :time, null: false, default: "17:00"
    add_column :outreach_campaigns, :timezone, :string, null: false, default: "America/New_York"
  end
end
2