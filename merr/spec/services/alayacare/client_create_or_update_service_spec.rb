# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::ClientCreateOrUpdateService do
  let(:service) { Alayacare::ClientCreateOrUpdateService }

  describe "create client" do
    context "who has an address" do
      let(:patient) { FactoryBot.create(:patient, :with_address, :with_user) }
      let(:present_expected_fields) { %w[first_name last_name address_line_one city state zipcode] }
      it "has expected keys in the body" do
        # make sure zipcode is valid
        patient.address.update(zipcode: "98103")

        body = service.new(patient, present_expected_fields).body

        expect(body[:demographics].keys).to include(:first_name, :last_name, :address, :city, :state, :zip)
        expect(body.keys).to include(:timezone)
      end
    end

    context "who does not have an address" do
      let(:patient) { FactoryBot.create(:patient, :with_user) }
      let(:present_expected_fields) { %w[first_name last_name address_line_one city state zipcode] }

      it "does not have an address block" do
        body = service.new(patient, present_expected_fields).body

        expect(body[:demographics].keys).to_not include(:address, :address_suite, :city, :state)
      end
    end

    context "with additional attributes" do
      let(:patient) { FactoryBot.create(:patient, :with_user) }

      it "adds custom fields" do
        patient.ehr_custom_import_attributes = {fcc_region: "TEST"}

        body = service.new(patient, []).body

        expect(body[:demographics][:fcc_region]).to eq("TEST")
      end
    end
  end
end
