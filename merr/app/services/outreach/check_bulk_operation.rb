# typed: true
# frozen_string_literal: true

module Outreach
  class CheckBulkOperation < ::ApplicationService
    def call
      bulk_ids = OutreachCampaignContact.pending.distinct.pluck(:kustomer_bulk_id).compact

      bulk_ids.each do |bulk_id|
        result = Kustomer::GetBulkRequestStatus.call(bulk_id)
        return result unless result.success?
  
        body = JSON.parse(result.body)
        status = body["data"]["attributes"]["status"]
  
        if status == "complete"
          OutreachCampaignContact.where(kustomer_bulk_id: bulk_id).update_all(status: "success")
          # TODO: capture failed (or partial fail?) status
        end
      end
    end
  end
end
