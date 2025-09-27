# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::GetArrivalWindow, type: :request do
  let!(:service) { Routing::GetArrivalWindow }

  context "when saving visit" do
    let!(:start_time) { DateTime.parse("2022-01-01T20:20:00 -0000") }
    let(:visit) do
      build(:visit, program:    create(:program, arrival_window_offset_minutes: 60),
                    start_time: start_time,
                    end_time:   start_time + 60.minutes,
                    patient:    create(:patient, address: create(:address)),
                    arrival_window_start: nil,
                    arrival_window_end: nil)
    end

    it "adds arrival window" do
      expect(visit.arrival_window_start).to be nil

      visit.patient.address.timezone = "UTC"

      visit.save

      expect(visit.arrival_window_start).to eq("2022-01-01T19:15:00 -0000".in_time_zone("UTC"))
      expect(visit.arrival_window_end).to eq("2022-01-01T21:15:00 -0000".in_time_zone("UTC"))
    end
  end

  context "using helper function" do
    # create blank instance for testing helper function
    let(:instance) { Routing::GetArrivalWindow.new(nil, nil, nil, nil, nil) }
    let(:start_time) { DateTime.parse("2022-01-01T20:20:20 -0000") }
    let(:timezone) { "America/Los_Angeles" }
    let(:block_schedule) { "6-9, 10-13, 18-20" }
    let(:offset) { 45 }
    let(:existing_window) { [DateTime.parse("2022-01-01T21:00:20 -0000"), DateTime.parse("2022-01-01T22:00:20 -0000")] }
    let(:default_offset) { Routing::GetArrivalWindow::DEFAULT_OFFSET_IN_MINUTES }

    it "returns offset with bad timezone" do
      res = instance.get_arrival_window(start_time, "INVALID", block_schedule, offset, existing_window)

      expect(res[0]).to eq(start_time - offset.minutes)
      expect(res[1]).to eq(start_time + offset.minutes)
    end

    it "returns default with no schedule or offset" do
      res = instance.get_arrival_window(start_time, timezone, nil, nil, nil)

      expect(res[0]).to eq(start_time - default_offset.minutes)
      expect(res[1]).to eq(start_time + default_offset.minutes)
    end

    it "returns default with incomplete existing_window" do
      existing_window[1] = nil
      res = instance.get_arrival_window(start_time, nil, block_schedule, offset, existing_window)

      expect(res[0]).to eq(start_time - default_offset.minutes)
      expect(res[1]).to eq(start_time + default_offset.minutes)
    end

    it "doesn't change timezone if start time in original arrival window" do
      start_time = DateTime.parse("2022-01-01T21:20:20 -0000")
      res = instance.get_arrival_window(start_time, timezone, block_schedule, offset, existing_window)

      expect(res[0]).to eq(existing_window[0])
      expect(res[1]).to eq(existing_window[1])
    end

    it "returns block schedule" do
      res = instance.get_arrival_window(start_time, timezone, block_schedule, offset, existing_window)

      expect(res[0]).to eq("2022-01-01T10:00:00".in_time_zone(timezone))
      expect(res[1]).to eq("2022-01-01T13:00:00".in_time_zone(timezone))
    end

    it "falls back to offset" do
      start_time = DateTime.parse("2022-01-01T10:00:00 -0000")
      res = instance.get_arrival_window(start_time, timezone, block_schedule, offset, existing_window)

      expect(res[0]).to eq(start_time - offset.minutes)
      expect(res[1]).to eq(start_time + offset.minutes)
    end

    it "works with start time at beginning of block schedule" do
      start_time = "2022-01-01T10:00:00".in_time_zone(timezone)
      res = instance.get_arrival_window(start_time, timezone, block_schedule, offset, existing_window)

      expect(res[0]).to eq("2022-01-01T10:00:00".in_time_zone(timezone))
      expect(res[1]).to eq("2022-01-01T13:00:00".in_time_zone(timezone))
    end

    it "works with start time at end of block schedule" do
      start_time = "2022-01-01T13:00:00".in_time_zone(timezone)
      res = instance.get_arrival_window(start_time, timezone, block_schedule, offset, existing_window)

      expect(res[0]).to eq("2022-01-01T10:00:00".in_time_zone(timezone))
      expect(res[1]).to eq("2022-01-01T13:00:00".in_time_zone(timezone))
    end
  end
end
