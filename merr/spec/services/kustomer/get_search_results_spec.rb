# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kustomer::GetSearchResults do
  context "with a few hundred results" do
    let(:search_id) { "6254958e93a82b001a157da1" }

    it "gets all of them" do
      res = described_class.call(search_id)
      expect(res).to be_success
      expect(res.payload.map {|r| r["id"] }).to match_array %w[
        611fcb6c43d4c677f524a11d
        6120195543d4c634d32d59dc
        61210214c48a295d4a40fb0f
        612108e06a205783b8761317
        61210d97c8acb9d03be67fde
        61210fda0d20ad67fa9c1a3b
        61211487cdf40944962f3163
        61211487f9c363cd0129c093
        61210214c48a296e6d40fb0c
        61210d95f9c363061829035c
        612108e00d20ad1af99b481f
        611be9dcdc0c0912652cb3e7
      ]
    end
  end

  context "with over 10,000 results" do
    let(:search_id) { "624f2a240c8bfe002199fd35" }

    it "gets all of them" do
      res = described_class.call(search_id)
      expect(res).to be_success
      expect(res.payload).to have(12_049).items
    end
  end
end
