# typed: true
# frozen_string_literal: true

module Outreach
  class SendActiveCampaignBatchesCronJob < ApplicationJob
    include ScheduledCronJob

    # Campaigns are checked every 5 minutes to see if more messages should be sent
    INTERVAL_MIN = 5
    self.cron_expression = "*/" + INTERVAL_MIN.to_s + " * * * *"

    def perform
      OutreachCampaign.active.find_each do |campaign|
        next unless self.class.time_is_allowed(campaign, Time.now) 

        result = Outreach::SendThrottledBatch.call(campaign, run_interval: INTERVAL_MIN.minutes)
        raise(StandardError, result) unless result.success?
      end
    end

    def self.time_is_allowed(campaign, time)
      local_date_and_time = time.in_time_zone(campaign.timezone)
      local_wday = local_date_and_time.wday
      local_hour = local_date_and_time.hour
      local_minute = local_date_and_time.min

      not_before_local_time = campaign.not_before_local_time_for_wday[local_wday]
      not_after_local_time = campaign.not_after_local_time_for_wday[local_wday]
      return false unless not_before_local_time.present? && not_after_local_time.present?

      min_hour = not_before_local_time.hour
      min_minute = not_before_local_time.min
      max_hour = not_after_local_time.hour
      max_minute = not_after_local_time.min

      gte_min = (min_hour < local_hour || (min_hour == local_hour && min_minute <= local_minute))
      lt_max = (local_hour < max_hour || (local_hour == max_hour && local_minute < max_minute))

      gte_min && lt_max
    end

  end
end
