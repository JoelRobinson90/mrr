# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::AddRetroactiveDriveTime, type: :request do
  let(:service) { Routing::AddRetroactiveDriveTime }

  context "with fp_id, location, and start times" do
    it "fetches drive times" do
      visits = [
        AlayacareApiVisit.new(
          fp_id:      "1227",
          location:   "29.678420,-95.333070",
          start_time: Time.zone.parse("2021-11-01 23:00:00")
        ),
        AlayacareApiVisit.new(
          fp_id:      "1227",
          location:   "29.753021,-95.341277",
          start_time: Time.zone.parse("2021-11-01 22:00:00")
        ),
        AlayacareApiVisit.new(
          fp_id:      "1227",
          location:   "29.750183,-95.366426",
          start_time: Time.zone.parse("2021-11-01 21:00:00")
        )
      ]

      result = service.call(visits)

      expect(result.success?).to be true

      expect(result.payload.pluck(:drive_time)).to eq([4, 7, 18])

      expect(result.payload.map {|v| v[:drive_distance].to_i }).to eq([0, 2, 9])
    end
  end
end
