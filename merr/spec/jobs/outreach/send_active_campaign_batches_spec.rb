# frozen_string_literal: true

require "rails_helper"

RSpec.describe Outreach::SendActiveCampaignBatchesCronJob do
  let(:campaign) do
    FactoryBot.create :outreach_campaign,
           name:                         "Health Net Warm IVR",
           active:                       true,
           kustomer_tag_id:              "test-ivr-trigger-tag",
           kustomer_conversation_fields: {
             programDisplayNameStr: "Health Net"
           },
           weekday_not_before_local_time: Time.utc(2000, 1, 1, 9, 1, 0),
           weekday_not_after_local_time: Time.utc(2000, 1, 1, 17, 0, 0),
           saturday_not_before_local_time: Time.utc(2000, 1, 1, 11, 0, 0),
           saturday_not_after_local_time: Time.utc(2000, 1, 1, 18, 0, 0),
           timezone: "Etc/GMT+4" # Note +4 is actually -4 see https://en.wikipedia.org/wiki/Tz_database#Area
  end

  context "time is allowed check" do
    it "allows times in range" do
      now = Time.utc(2022, 5, 25, 18, 26, 15)
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be true
    end

    it "does not does not allow time outside of range" do
      now = Time.utc(2022, 5, 25, 23, 26, 15)
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false

      now = Time.utc(2022, 5, 25, 10, 26, 15)
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false
    end

    it "uses different times for weekends" do
      now = Time.utc(2022, 6, 24, 14, 0, 0) # Friday
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be true

      now = Time.utc(2022, 6, 25, 14, 0, 0) # Saturday
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false

      now = Time.utc(2022, 6, 24, 16, 0, 0) # Friday
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be true

      now = Time.utc(2022, 6, 25, 16, 0, 0) # Saturday
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be true

      now = Time.utc(2022, 6, 24, 21, 30, 0) # Friday
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false

      now = Time.utc(2022, 6, 25, 21, 30, 0) # Saturday
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be true
    end

    it "does not allow weekend time unless configured to" do
      now = Time.utc(2022, 6, 26, 14, 0, 0) # Sunday
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false

      now = Time.utc(2022, 6, 26, 16, 0, 0)
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false

      now = Time.utc(2022, 6, 26, 21, 0, 0)
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false
    end

    it "respects campaign timezone" do
      now = Time.utc(2022, 5, 25, 22, 26, 15)
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false

      pacific_campaign = campaign.dup
      pacific_campaign.timezone="Etc/GMT+7"
      actual = described_class.time_is_allowed(pacific_campaign, now)
      expect(actual).to be true
    end

    it "does not allow surprise Sunday outreaches" do
      now = Time.utc(2022, 6, 27, 0, 0, 5)
      hawaiian_campaign = campaign.dup
      hawaiian_campaign.timezone="Etc/GMT+10"
      hawaiian_campaign.sunday_not_before_local_time = Time.utc(2000, 1, 1, 9, 1, 0),
      hawaiian_campaign.sunday_not_after_local_time = Time.utc(2000, 1, 1, 17, 0, 0),
      actual = described_class.time_is_allowed(hawaiian_campaign, now)
      expect(actual).to be false
    end

    it "supports minute level granularity" do
      now = Time.utc(2022, 5, 25, 13, 0, 0)
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be false

      now = Time.utc(2022, 5, 25, 13, 1, 0)
      actual = described_class.time_is_allowed(campaign, now)
      expect(actual).to be true
    end
  end
end