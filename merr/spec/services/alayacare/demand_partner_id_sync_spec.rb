# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::DemandPartnerIdSyncService do
  let(:service) { Alayacare::DemandPartnerIdSyncService }
  let(:demand_partner_no_match) { FactoryBot.create(:demand_partner) }

  describe "sync demand partners and client groups" do
    it "updates the id for a demand partner found in AC" do
      demand_partner_match = FactoryBot.create(:demand_partner, name: "Bright Healthcare")
      service.call
      demand_partner_match.reload
      expect(demand_partner_match.alayacare_id).not_to be_nil
    end

    it "does not update the id for a demand partner not found in AC" do
      service.call
      demand_partner_no_match.reload
      expect(demand_partner_no_match.alayacare_id).to be_nil
    end
  end
end