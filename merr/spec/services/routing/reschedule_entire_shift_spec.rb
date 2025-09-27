# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::RescheduleEntireShift, type: :request do
  let(:service) { Routing::RescheduleEntireShift }

  let!(:date) { "2022-01-01" }

  let!(:old_fp) { create(:field_provider, address: build(:address, :los_angeles)) }

  let!(:new_fp) { create(:field_provider, address: nil) }

  let!(:visits_to_reschedule) do
    [
      create(:visit, field_provider: old_fp, start_time: "#{date}T12:00-0800", end_time: "#{date}T13:00-0800"),
      create(:visit, field_provider: old_fp, start_time: "#{date}T13:00-0800", end_time: "#{date}T14:00-0800")
    ]
  end

  context "Without conflicts" do
    let!(:non_conflicting_visit) do
      create(:visit, field_provider: new_fp, start_time: "#{date}T14:00-0800", end_time: "#{date}T15:00-0800")
    end

    it "reschedules all visits" do
      result = service.call(date, old_fp, new_fp)

      expect(result.success?).to be true
      expect(result.message).to eq("Rescheduled 2 visits")

      visits_to_reschedule.each do |visit|
        visit.reload
        expect(visit.field_provider).to eq(new_fp)
      end
    end
  end

  context "With conflict" do
    let!(:conflicting_visit) do
      create(:visit, field_provider: new_fp, start_time: "#{date}T12:30-0800", end_time: "#{date}T13:30-0800")
    end

    it "doesn't reschedule any visits" do
      result = service.call(date, old_fp, new_fp)

      expect(result.success?).to be false
      expect(result.error).to eq("Visit from 12:00pm to  1:00pm is blocked by visit from 12:30pm to  1:30pm")

      visits_to_reschedule.each do |visit|
        visit.reload
        expect(visit.field_provider).to eq(old_fp)
      end
    end
  end
end
