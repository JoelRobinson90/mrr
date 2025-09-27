# frozen_string_literal: true

module Mutations
  class UpdateOutreachCampaignActivity < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :active, Boolean, required: true

    field :outreach_campaign, Types::OutreachCampaignType, null: true
    field :errors, [String], null: false

    def resolve(id:, active:)
      outreach_campaign = OutreachCampaign.find(id)
      return {outreach_campaign: nil, errors: [unauthorized_error]} unless can?(:update, outreach_campaign)

      if outreach_campaign.update(active: active)
        {outreach_campaign: outreach_campaign, errors: []}
      else
        {outreach_campaign: nil, errors: outreach_campaign.errors.full_messages}
      end
    end
  end
end
