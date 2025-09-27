# frozen_string_literal: true

require "rails_helper"

RSpec.describe Outreach::ContactPatient do
  let(:active) { false }

  let(:campaign) do
    create :outreach_campaign,
           name:                         "Health Net Warm IVR",
           active:                       active,
           kustomer_tag_id:              "test-ivr-trigger-tag",
           kustomer_conversation_fields: {
             programDisplayNameStr: "Health Net"
           }
  end

  before do
    allow(Outreach::CreateKustomerConversation).to receive(:call)
  end

  context "active campaign" do
    let(:active) { true }

    it "creates a kustomer conversation" do
      described_class.call(campaign, "test-customer-id")
      expect(Outreach::CreateKustomerConversation).to have_received(:call).with(
        customer_id:   "test-customer-id",
        tags:          ["test-ivr-trigger-tag"],
        custom_fields: {
          "regardingProgramStr"   => "Door to door outreach",
          "programDisplayNameStr" => "Health Net"
        },
        name:          "Health Net Warm IVR"
      )
    end

    it "creates a kustomer conversation with no tag if in manual mode" do
      described_class.call(campaign, "test-customer-id", manual_mode: true)
      expect(Outreach::CreateKustomerConversation).to have_received(:call).with(
        customer_id:   "test-customer-id",
        tags:          [],
        custom_fields: {
          "regardingProgramStr"   => "Door to door outreach",
          "programDisplayNameStr" => "Health Net"
        },
        name:          "Health Net Warm IVR"
      )
    end
  end

  context "inactive campaign" do
    let(:active) { false }

    it "does not create a kustomer conversation" do
      described_class.call(campaign, "test-customer-id")
      expect(Outreach::CreateKustomerConversation).not_to have_received(:call)
    end
  end
end
