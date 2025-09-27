# frozen_string_literal: true

module Outreach
  class SendThrottledBatch < ApplicationService
    attr_reader :outreach_campaign, :run_interval, :batch_size

    delegate :rate_per_hour, to: :outreach_campaign

    # Accepts an OutreachCampaign
    # If batch_size number is passed, sends (up to) that number of 'created' contacts,
    #   or if run_interval is passed (i.e. `5.minutes`) it will send the appropriate
    #   batch size according to campaign rate_per_hour.
    # Updates OutreachCampaignContact status as appropriate

    def initialize(outreach_campaign, run_interval: nil, batch_size: nil)
      @outreach_campaign = outreach_campaign
      @run_interval = run_interval
      @batch_size = batch_size
    end

    def call
      unless run_interval || batch_size
        return OpenStruct.new(success?: false,
                              error:    "Must supply run interval or batch size")
      end

      count_to_send = batch_size || count_per_interval
      contacts = outreach_campaign.contacts.created.order(id: :asc).first(count_to_send)

      conversations_body = new_conversations_body(contacts)
      result = Kustomer::BulkCreateConversations.call(conversations_body)
      return result unless result.success?

      body = JSON.parse(result.body)
      bulk_id = body["data"]["id"]

      OutreachCampaignContact.where(id: contacts).update_all(
        status:           "pending",
        kustomer_bulk_id: bulk_id
      )

      # TODO: schedule kustomer bulk checker job

      if outreach_campaign.contacts.created.count.zero?
        # TODO: if campaign has no more, mark as done
        outreach_campaign.update!(active: false)
      end

      OpenStruct.new(
        success?: result.success?,
        payload:  body
      )
    end

    # TODO: This rounds down and can result in lower effective rate per hour
    def count_per_interval
      times_ran_per_hour = 1.hour / run_interval
      (rate_per_hour / times_ran_per_hour).floor
    end

    def new_conversations_body(contacts)
      contacts.map {|contact| Outreach::NewConversationPayload.call(contact) }
    end
  end
end
