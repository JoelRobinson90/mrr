# frozen_string_literal: true

module Outreach
  class ContactPatient < ApplicationService
    attr_reader :outreach_campaign, :kustomer_customer_id, :manual_mode

    # Creates one conversation for one Kustomer customer

    def initialize(outreach_campaign, kustomer_customer_id, manual_mode: false)
      @outreach_campaign = outreach_campaign
      @kustomer_customer_id = kustomer_customer_id
      @manual_mode = manual_mode
    end

    def call
      return OpenStruct.new(success?: false, error: "Outreach campaign is not active") unless outreach_campaign.active?

      Outreach::CreateKustomerConversation.call(
        customer_id:   kustomer_customer_id,
        # Manual mode creates a conversation without the trigger tag, since the tag
        # will actually contact the patient
        tags:          manual_mode ? [] : [outreach_campaign.kustomer_tag_id],
        custom_fields: outreach_campaign.kustomer_custom_fields,
        name:          outreach_campaign.name
      )
    end
  end
end
