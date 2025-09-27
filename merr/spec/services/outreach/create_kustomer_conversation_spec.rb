# frozen_string_literal: true

require "rails_helper"

RSpec.describe Outreach::CreateKustomerConversation do
  let(:kustomer_api) { instance_double(Authentication::Api) }
  let(:create_conversation_response) { double("create conversation response") }
  let(:update_tags_response) { double("update tags response") }

  before do
    allow(Authentication::Api).to receive(:new).with(Authentication::KustomerBroker) { kustomer_api }

    allow(kustomer_api).to receive(:post).with("conversations", anything) { create_conversation_response }
    allow(Kustomer::Helper).to receive(:parse_response).with(create_conversation_response) do
      OpenStruct.new(
        success?: true,
        body:     {
          data: {
            id: "new-conversation-id"
          }
        }.to_json
      )
    end

    allow(kustomer_api).to receive(:post).with("conversations/new-conversation-id/tags", anything) { update_tags_response }
    allow(Kustomer::Helper).to receive(:parse_response).with(update_tags_response) do
      OpenStruct.new(
        success?: true,
        body:     {
          data: {
            id: "new-conversation-id"
          }
        }.to_json
      )
    end
  end

  it "creates a Kustomer conversation for the specified customer" do
    result = described_class.call(
      name:          "Dungeonmaster Outreach",
      customer_id:   "customer-to-be-reached",
      tags:          ["trigger-tag-id"],
      custom_fields: {
        partnerDisplayNameStr: "Chris' RPG Dungeon",
        otherFieldStr:         "Learn to be a dungeonmaster"
      }
    )

    expect(result.success?).to be true
    expect(result.payload[:conversation_id]).to eq "new-conversation-id"

    expect(kustomer_api).to have_received(:post).with("conversations", {
                                                        customer: "customer-to-be-reached",
                                                        name:     "[Auto Outreach] Dungeonmaster Outreach",
                                                        custom:   {
                                                          partnerDisplayNameStr: "Chris' RPG Dungeon",
                                                          otherFieldStr:         "Learn to be a dungeonmaster"
                                                        }
                                                      })
    expect(kustomer_api).to have_received(:post).with("conversations/new-conversation-id/tags", ["trigger-tag-id"])
  end
end
