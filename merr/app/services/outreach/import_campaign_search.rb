# frozen_string_literal: true

module Outreach
  class ImportCampaignSearch < ::ApplicationService
    attr_reader :outreach_campaign

    def initialize(outreach_campaign)
      @outreach_campaign = outreach_campaign
    end

    def call
      search_res = Kustomer::GetSearchResults.call(outreach_campaign.kustomer_search_id)
      return search_res unless search_res.success?

      kustomer_results = search_res.payload
      new_records = import_results(kustomer_results)

      OpenStruct.new(success?: true, payload: new_records)
    end

    private

    def import_results(kustomer_results)
      kustomer_results.each_slice(100).map do |results|
        outreach_campaign.contacts.insert_all(
          results.map do |result|
            {
              kustomer_customer_id: result["id"],
              updated_at:           Time.zone.now,
              created_at:           Time.zone.now
            }
          end
        )
      end.flatten
    end
  end
end
