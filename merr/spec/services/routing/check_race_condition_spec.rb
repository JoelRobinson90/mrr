# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::CheckRaceCondition do
  let(:service) { Routing::CheckRaceCondition }

  describe "check race condition" do
    let(:field_provider) { create(:field_provider, first_name: "Billy", last_name: "Bob") }
    let(:program) { create(:program, minutes_of_buffer_time: 10, max_grace_period: 0) }
    let(:new_visit) do
      build(:visit, program: program,
                    field_provider: field_provider,
                    start_time: Time.parse("2021-11-01 12:00:00"),
                    end_time: Time.parse("2021-11-01 13:00:00"))
    end

    let!(:overlapping_visit) do
      create(:visit, program: program,
                     field_provider: field_provider,
                     start_time: Time.parse("2021-11-01 12:30:00"),
                     end_time: Time.parse("2021-11-01 13:30:00"))
    end

    let!(:near_overlap_visit) do
      create(:visit, program: program,
                     field_provider: field_provider,
                     start_time: Time.parse("2021-11-01 13:05:00"),
                     end_time: Time.parse("2021-11-01 14:00:00"))
    end

    let!(:no_overlap_visit) do
      create(:visit, program: program,
                     field_provider: field_provider,
                     start_time: Time.parse("2021-11-01 14:00:00"),
                     end_time: Time.parse("2021-11-01 15:00:00"))
    end

    context "with no conflicting visits" do
      let(:other_field_provider) { create(:field_provider) }

      it "should not find race condition" do
        # doesn't conflict on FP
        new_visit.field_provider = other_field_provider
        expect(service.call(new_visit).success?).to be true

        # conflicts on FP but not on time
        new_visit.field_provider = field_provider
        new_visit.start_time = Time.parse("2021-11-01 16:00:00")
        new_visit.start_time = Time.parse("2021-11-01 17:00:00")
        expect(service.call(new_visit).success?).to be true
      end
    end

    context "with conflicing visits" do

      it "should find race condition" do
        # Conflicts with overlaping and near overlaping
        result = service.call(new_visit)
        expect(result.success?).to be false
        conflicts = "#{overlapping_visit.ma_id} and #{near_overlap_visit.ma_id}"
        expected = "Visit with Billy Bob from 2021-11-01 12:00:00 UTC to 2021-11-01 13:00:00 UTC (9 minute buffer) conflicts with existing visits #{conflicts}."
        expect(result.error).to eq(expected)

        # Conflicts with overlaping only due to grace period
        program.update(max_grace_period: 20)
        result = service.call(new_visit)
        expect(result.success?).to be false
        expect(result.error).to eq("Visit with Billy Bob from 2021-11-01 12:00:00 UTC to 2021-11-01 13:00:00 UTC (-11 minute buffer) conflicts with existing visit #{overlapping_visit.ma_id}.")

        # Doesn't block on canceled visits
        overlapping_visit.update(canceled: true, cancel_code: create(:cancel_code))
        expect(overlapping_visit.errors.blank?).to be true
        expect(service.call(new_visit).success?).to be true
      end
    end
  end
end
