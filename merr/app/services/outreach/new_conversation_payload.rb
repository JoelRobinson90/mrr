# frozen_string_literal: true

module Outreach
  class NewConversationPayload < ApplicationService
    attr_reader :outreach_campaign_contact, :manual_mode

    delegate :outreach_campaign, :kustomer_customer_id, to: :outreach_campaign_contact
    delegate :kustomer_tag_id, :kustomer_custom_fields, :name, to: :outreach_campaign

    def initialize(outreach_campaign_contact)
      @outreach_campaign_contact = outreach_campaign_contact
      @manual_mode = manual_mode
    end

    def call
      {
        customer: kustomer_customer_id,
        tags:     [kustomer_tag_id],
        custom:   kustomer_custom_fields,
        name:     "[Auto Outreach] #{name}",
        status:   "done"
      }
    end
  end
end
