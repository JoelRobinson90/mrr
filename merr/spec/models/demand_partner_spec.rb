# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_partners
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  short_name      :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  alayacare_id    :integer
#  ma_id           :string           indexed
#
# Indexes
#
#  index_demand_partners_on_ma_id  (ma_id)
#
require "rails_helper"

RSpec.describe DemandPartner, type: :model do
  context "with multiple athena departments" do
    let(:demand_partner) { create(:demand_partner) }
    let!(:pst_department) do
      create(:athena_department, demand_partner: demand_partner, timezone: "America/Los_Angeles", athena_id: 1)
    end
    let!(:est_department) do
      create(:athena_department, demand_partner: demand_partner, timezone: "America/New_York", athena_id: 2)
    end
    let!(:phoenix_department) do
      create(:athena_department, demand_partner: demand_partner, timezone: "America/Phoenix", athena_id: 3)
    end

    it "finds correct athena department id" do
      patient = build(:patient, address: build(:address, :los_angeles))
      res = demand_partner.get_athena_department(patient)
      expect(res).to eq(pst_department)

      patient = build(:patient, address: build(:address, :florida))
      res = demand_partner.get_athena_department(patient)
      expect(res).to eq(est_department)

      patient = build(:patient, address: build(:address, timezone: "America/Phoenix"))
      res = demand_partner.get_athena_department(patient)
      expect(res).to eq(phoenix_department)
    end

    it "returns no athena department id if not matched" do
      patient = build(:patient, address: build(:address, zipcode: 50_112))
      res = demand_partner.get_athena_department(patient)
      expect(res).to be nil
    end
  end
end
