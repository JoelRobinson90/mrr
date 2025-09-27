# frozen_string_literal: true

module Queries
  module OutreachCampaignQueries
    def outreach_campaigns(active: nil)
      outreach_campaigns = OutreachCampaign.accessible_by(current_ability).order(:id)
      outreach_campaigns = outreach_campaigns.where(active: active) unless active.nil?
      outreach_campaigns
    end
  end
end
