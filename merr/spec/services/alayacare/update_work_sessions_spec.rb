# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::UpdateWorkSessions do
  let(:service) { Alayacare::UpdateWorkSessions }

  describe "a work session data stream" do
    let(:visit) { create(:visit) }

    let(:initial_ac_work_session) do
      {
        "clock_in"          => "2017-07-08T13:30:00+00:00",
        "clock_in_location" => {
          "lat" => 45.518,
          "lng" => -73.582
        }
      }
    end

    let(:updated_ac_work_session) do
      {
        "clock_in"           => "2017-07-08T13:30:00+00:00",
        "clock_out"          => "2017-07-08T14:30:00+00:00",
        "clock_in_location"  => {
          "lat" => 45.518,
          "lng" => -73.582
        },
        "clock_out_location" => {
          "lat" => 45.518,
          "lng" => -73.582
        }
      }
    end

    let(:additional_ac_work_session) do
      {
        "clock_in"          => "2017-07-08T14:30:00+00:00",
        "clock_in_location" => {
          "lat" => 45.518,
          "lng" => -73.582
        }
      }
    end

    it "keeps postgres version up to date" do
      expect(visit.work_sessions.count).to eq(0)

      # initial creation
      result = service.call(visit, [initial_ac_work_session])
      visit.reload
      expect(result.success?).to be true
      expect(result.message).to eq("Synced work sessions. Updated: 0 Found: 0 Created: 1")
      expect(visit.work_sessions.count).to eq(1)
      work_session = visit.work_sessions.first
      expect(work_session.field_provider).to eq(visit.field_provider)
      expect(work_session.clock_in).to eq(Time.zone.parse(initial_ac_work_session["clock_in"]))
      expect(work_session.clock_in_location).to eq("45.518,-73.582")

      # idempotent
      result = service.call(visit, [initial_ac_work_session])
      visit.reload
      expect(result.success?).to be true
      expect(result.message).to eq("Synced work sessions. Updated: 0 Found: 1 Created: 0")
      expect(visit.work_sessions.count).to eq(1)

      # add clock out time to existing work session
      result = service.call(visit, [updated_ac_work_session])
      visit.reload
      expect(result.success?).to be true
      expect(result.message).to eq("Synced work sessions. Updated: 1 Found: 0 Created: 0")
      expect(visit.work_sessions.count).to eq(1)

      # can handle multiple work sessions
      result = service.call(visit, [updated_ac_work_session, additional_ac_work_session])
      expect(result.success?).to be true
      expect(result.message).to eq("Synced work sessions. Updated: 0 Found: 1 Created: 1")
      expect(visit.work_sessions.count).to eq(2)

      # can handle bad input
      result = service.call(visit, [{laskdfjl: "sdlfjsldkfj"}])
      expect(result.success?).to be false
      expect(visit.work_sessions.count).to eq(2)
    end
  end
end
