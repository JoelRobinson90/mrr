# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::SlotScorer, type: :request do
  let!(:service) { Routing::SlotScorer }
  let!(:target_date) { Date.parse("2021-11-01") }

  context "with all required parameters" do
    let!(:slot) do
      {
        fp_id:          "5",
        appt_start:     target_date + 14.hours,
        appt_end:       target_date + 15.hours,
        expected_drive: 30,
        contiguous:     true
      }
    end

    let!(:shift) do
      {
        fp_id:      "5",
        start_time: target_date + 6.hours,
        end_time:   target_date + 18.hours
      }
    end

    let!(:appointments) do
      [
        {
          fp_id:      "5",
          start_time: target_date + 7.hours,
          end_time:   target_date + 8.hours
        },
        {
          fp_id:      "5",
          start_time: target_date + 9.hours,
          end_time:   target_date + 10.hours
        }
      ]
    end

    let!(:weights) do
      {
        drive_weight:                    80,
        proximity_weight:                10,
        utilization_weight:              10,
        shift_shortening_penalty_weight: 0
      }
    end

    let!(:earliest_time) { target_date.beginning_of_day }
    let!(:latest_time) { (target_date + 10.days).end_of_day }
    let!(:buffer_time) { 30 }
    let!(:min_shift_length) { 8.0 }
    let!(:drive_time_breakpoints) { nil }

    let(:instance) do
      service.new(slot, shift, appointments, weights, earliest_time, latest_time, buffer_time, min_shift_length,
                  drive_time_breakpoints)
    end

    it "gets utilization score" do
      # Two hours are covered by visits, and there are two 30 minute buffers between the two visits.
      # So 3 hours are covered, out of 12 which is 25 percent, and the score is the inverse of that.
      expect(instance.get_utilization_score.round).to eq(75)
    end

    it "gets drive score" do
      # Drive time of 30 is 25% of max drive time of 120. Score is inverse of that normalized ratio.
      expect(instance.get_drive_score.round).to eq(75)
    end

    it "gets proximity score" do
      expect(instance.get_proximity_score.round).to eq(100)
    end

    context "missing parameter" do
      it "has a 100 shift_shortening_score if min_shfit_length is missing" do
        instance = service.new(slot, shift, appointments, weights, earliest_time, latest_time, buffer_time,
                               nil, nil)

        expect(instance.get_shift_shortening_score.round).to eq(100)
      end
    end

    context "non-contiguous slot" do
      let(:slot) do
        {
          expected_drive: 60,
          contiguous:     false
        }
      end

      it "gets reduced drive score" do
        instance = service.new(slot, shift, appointments, weights, earliest_time, latest_time, buffer_time,
                               min_shift_length, drive_time_breakpoints)

        # drive score is 50% of max, but then 20 points are taken off for being non-contiguous.
        expect(instance.get_drive_score.round).to eq(30)

        slot[:expected_drive] = 150

        instance = service.new(slot, shift, appointments, weights, earliest_time, latest_time, buffer_time,
                               min_shift_length, drive_time_breakpoints)

        # If numbers go below zero, return zero.
        expect(instance.get_drive_score).to eq(0)
      end
    end

    it "combines all scores" do
      result = instance.call

      expected = {
        total_score:                    77,
        drive_score:                    75,
        utilization_score:              75,
        proximity_score:                100,
        shift_shortening_penalty_score: 100
      }

      expect(result.success?).to be true
      expect(result.payload.except(:precise_score)).to eq(expected)

      # Precise score is not returned to user, but is used for sorting.
      expect((76...79).include?(result.payload[:precise_score])).to be true
    end
  end

  context "using a helper function" do
    let(:instance) { service.new(nil, nil, nil, nil, nil, nil, nil, nil, nil) }

    it "normalizes times" do
      t_start = Time.zone.now + 10.hours
      t_target = Time.zone.now + 12.hours
      t_end = Time.zone.now + 20.hours

      # Target is 20% of the way between start and end.
      expect(instance.normalized_value(t_target, min: t_start, max: t_end)).to eq(20)
    end

    it "normalizes integers" do
      # Test rounding and default min
      expect(instance.normalized_value(5, max: 15).round).to eq(33)

      # Test with min
      expect(instance.normalized_value(10, min: 5, max: 30)).to eq(20)

      # Test overflow
      expect(instance.normalized_value(50, min: 5, max: 30)).to eq(100)

      # Test underflow
      expect(instance.normalized_value(0, min: 5, max: 30)).to eq(0)

      # Corner cases
      expect(instance.normalized_value(10, min: 5, max: 5)).to eq(100)
      expect(instance.normalized_value(2, min: 5, max: 5)).to eq(0)
    end

    it "exponentially normalizes integers" do
      # Test smaller than min
      expect(instance.exponential_normalized_value(0, min: 5, max: 20)).to eq(0)

      # Test equal to min
      expect(instance.exponential_normalized_value(5, min: 5, max: 20)).to eq(0)

      # Test greater than max
      expect(instance.exponential_normalized_value(25, min: 5, max: 20)).to eq(100)

      # Test equal to max
      expect(instance.exponential_normalized_value(20, min: 5, max: 20)).to eq(100)

      # Test close to min
      expect(instance.exponential_normalized_value(1, min: 0, max: 20)).to be < 1

      # Test close to max
      expect(instance.exponential_normalized_value(19, min: 0, max: 20)).to be > 90

      # Test negative range
      expect(instance.exponential_normalized_value(19, min: 0, max: -20)).to eq(100)
    end

    it "interpolates breakpoints" do
      # with no breakpoints
      expect(instance.interpolate_drive_time_breakpoints(60, nil, 0, 120).round).to eq(50)
      expect(instance.interpolate_drive_time_breakpoints(60, [], 0, 120).round).to eq(50)
      expect(instance.interpolate_drive_time_breakpoints(0, [], 0, 120).round).to eq(100)
      expect(instance.interpolate_drive_time_breakpoints(120, [], 0, 120).round).to eq(0)
      expect(instance.interpolate_drive_time_breakpoints(-10, [], 0, 120).round).to eq(100)
      expect(instance.interpolate_drive_time_breakpoints(1000, [], 0, 120).round).to eq(0)

      expect(instance.interpolate_drive_time_breakpoints(60, [{drive: 60, score: 25}], 0, 120).round).to eq(25)
      expect(instance.interpolate_drive_time_breakpoints(30, [{drive: 60, score: 0}], 0, 120).round).to eq(50)

      expect(instance.interpolate_drive_time_breakpoints(0, [{drive: 0, score: 100}], 0, 120).round).to eq(100)
      expect(instance.interpolate_drive_time_breakpoints(120, [{drive: 120, score: 0}], 0, 120).round).to eq(0)

      breakpoints = [
        {drive: 10, score: 90},
        {drive: 30, score: 60},
        {drive: 45, score: 30},
        {drive: 60, score: 10}
      ]
      expect(instance.interpolate_drive_time_breakpoints(35, breakpoints, 0, 120).round).to eq(50)
      expect(instance.interpolate_drive_time_breakpoints(5, breakpoints, 0, 120).round).to eq(95)
      expect(instance.interpolate_drive_time_breakpoints(30, breakpoints, 0, 120).round).to eq(60)
      expect(instance.interpolate_drive_time_breakpoints(90, breakpoints, 0, 120).round).to eq(5)

      expect(instance.interpolate_drive_time_breakpoints(-5, [{drive: -10, score: 110}], 0, 120).round).to eq(100)
    end
  end
end
