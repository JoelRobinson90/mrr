# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::UpdateServiceInstructions do
  let(:service) { Alayacare::UpdateServiceInstructions }

  describe "add service instructions" do
    let(:alayacare_visit_id) { 729 }

    it "should fail with missing external_id and alayacare id" do
      response = service.call(alayacare_id: nil,
                              external_id: nil,
                              text: 'test')

      expect(response.success?).to be false
      expect(response.error).to eq("External_id or Alayacare_id required.")
    end

    context "with Alayacare_id" do
      let(:alayacare_visit_id) { 729 }
      let(:content) { "TEST AC NOTE" }

      it "should update service instructions" do
        response = service.call(alayacare_id: alayacare_visit_id, external_id: nil, text: content)
        expect(response.success?).to be true
      end
    end

    context "with external_id" do
      let!(:external_id) { "external_8408" }
      let!(:address) { FactoryBot.create(:address, notes: nil) }
      let!(:patient) { FactoryBot.create(:patient, address: address) }
      let!(:visit) { create(:visit, external_id: external_id, patient: patient) }
      let(:content) { "TEST LOCAL NOTE" }

      it "should update service instructions" do

        # Doesn't save blank string if notes is blank.
        response = service.call(external_id: external_id, alayacare_id: nil, text: "")
        expect(response.message).to eq("No update needed.")

        # Actual update.
        response = service.call(external_id: external_id, alayacare_id: nil, text: content)
        expect(response.success?).to be true

        address.reload

        expect(address.notes).to eq(content)

        # Doesn't re-save same notes.
        response = service.call(external_id: external_id, alayacare_id: nil, text: content)
        expect(response.message).to eq("No update needed.")


      end
    end
  end
end
