# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::ClientCreationService do
  let(:service) { Alayacare::ClientCreationService }

  describe "create client" do
    context "who has an address" do
      let(:patient) { FactoryBot.create(:patient, :with_address, :with_user) }
      it "has an address block in the body" do
        body = service.new(patient).body

        expect(body[:demographics].keys).to include(:address, :address_suite, :city, :state)
      end
    end

    context "who does not have an address" do
      let(:patient) { FactoryBot.create(:patient, :with_user) }
      it "does not have an address block" do
        body = service.new(patient).body

        expect(body[:demographics].keys).to_not include(:address, :address_suite, :city, :state)
      end
    end
  end
end
