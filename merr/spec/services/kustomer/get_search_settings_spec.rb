# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kustomer::GetSearchSettings do
  let(:search_id) { "624f2a240c8bfe002199fd35" }

  it "returns data for a saved search" do
    result = described_class.call(search_id)
    expect(result).to be_success

    body = JSON.parse(result.body)
    expect(body["data"]["id"]).to eq search_id
  end
end
