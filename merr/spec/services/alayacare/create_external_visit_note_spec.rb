# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::CreateExternalVisitNote do
  let(:service) { Alayacare::CreateExternalVisitNote }

  describe "add note" do
    let(:alayacare_visit_id) { 729 }

    it "should fail with missing visit id" do
      response = service.call(nil, "text")
      expect(response.success?).to be false
    end

    it "should create note" do
      response = service.call(alayacare_visit_id, "TEST NOTE")
      expect(response.success?).to be true

      body = JSON.parse(response.body)

      expect(body["notes"][-1]["text"]).to eq("TEST NOTE")
    end

    context "with user" do
      let(:admin) { create(:medarrive_admin, first_name: "Bob", last_name: "Hope") }

      it "should create note with signature" do
        response = service.call(alayacare_visit_id, "TEST NOTE", admin.user)
        expect(response.success?).to be true

        body = JSON.parse(response.body)

        expect(body["notes"][-1]["text"]).to eq("TEST NOTE -Bob Hope")
      end
    end
  end
end
