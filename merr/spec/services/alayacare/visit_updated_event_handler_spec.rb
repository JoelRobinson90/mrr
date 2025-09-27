# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::VisitUpdatedEventHandler do
  let(:service) { Alayacare::VisitUpdatedEventHandler }

  describe "Receiving event with clock in data" do
    # This visit ID is in AC with some work session data and a cancel code on Oct 27th
    let(:visit) { create(:visit, external_id: "Visit_VMNEt2frXJFZvELf") }

    let!(:cancel_code) { create(:cancel_code, code: "Patient Refused Visit") }

    it "updates times, cancel status, and work sessions" do
      expect(visit.work_sessions.count).to eq(0)

      result = service.call(visit.external_id)
      expect(result.success?).to be true
      visit.reload

      expect(visit.work_sessions.count).to eq(1)
      expect(result.message).to eq("SQS event processor: Updated visit and work sessions (Synced work sessions. Updated: 0 Found: 0 Created: 1)")

      expect(visit.start_time).to eq(Time.zone.parse("2022-10-27T19:35:00+00:00"))
      expect(visit.end_time).to eq(Time.zone.parse("2022-10-27T20:05:00+00:00"))

      expect(visit.canceled).to be true
      expect(visit.cancel_code.code).to eq("Patient Refused Visit")
    end
  end
end
