class AddWeekendCampaignSchedule < ActiveRecord::Migration[6.1]
  def change
    rename_column :outreach_campaigns, :not_before_local_time, :weekday_not_before_local_time
    rename_column :outreach_campaigns, :not_after_local_time, :weekday_not_after_local_time 
    add_column :outreach_campaigns, :saturday_not_before_local_time, :time, null: true
    add_column :outreach_campaigns, :saturday_not_after_local_time, :time, null: true
    add_column :outreach_campaigns, :sunday_not_before_local_time, :time, null: true
    add_column :outreach_campaigns, :sunday_not_after_local_time, :time, null: true
  end
end