module Mutations
  class ImportOutreachCampaignContacts < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      outreach_campaign = OutreachCampaign.find(id)
      return {success: false, errors: [unauthorized_error]} unless can?(:import, outreach_campaign)

      Outreach::ImportCampaignSearch.delay.call(outreach_campaign)

      {success: true, errors: []}
    end
  end
end
