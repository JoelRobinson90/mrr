# frozen_string_literal: true

require "rails_helper"

RSpec.describe Outreach::ImportCampaignSearch do
  let(:campaign) { create :outreach_campaign, kustomer_search_id: "test-search-id" }

  let!(:contact) do
    create :outreach_campaign_contact, outreach_campaign: campaign, kustomer_customer_id: "customer-id-1",
status: "success", updated_at: 1.day.ago
  end

  let(:mock_search_results) do
    200.times.map do |i|
      {"id" => "customer-id-#{i}"}
    end
  end

  before do
    allow(Kustomer::GetSearchResults).to receive(:call) do
      OpenStruct.new(success?: true, payload: mock_search_results)
    end
  end

  it "saves new customers" do
    existing_contact_updated_at = contact.updated_at
    expect { described_class.call(campaign) }.to change { campaign.reload.contacts.count }.by(199)
    expect(Kustomer::GetSearchResults).to have_received(:call).with("test-search-id")

    contact.reload
    expect(contact.updated_at).to eq(existing_contact_updated_at)
    expect(contact.status).to eq("success")
  end
end
