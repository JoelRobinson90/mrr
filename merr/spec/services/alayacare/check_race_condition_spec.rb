# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::CheckRaceCondition do
  let(:service) { Alayacare::CheckRaceCondition }

  describe "check race condition" do
    # random non-existant FP id
    let!(:field_provider) { create(:field_provider, external_id: "s4f43f34f34f4fvj") }
    let!(:patient) { create(:patient, external_id: "8407") }
    let!(:program) { create(:program, minutes_of_buffer_time: 15, max_grace_period: 0) }
    let!(:visit_type) { create(:visit_type, programs: [program], alayacare_id: "6") }
    let(:visit) do
      build(:visit, program: program, visit_type: visit_type, field_provider: field_provider, patient: patient,
                    start_time: Time.zone.now + 23.hours, end_time: Time.zone.now + 24.hours)
    end


    context "with no conflicting visits" do
      it "should not find race condition" do
        expect(service.call(visit).success?).to be true
      end
    end

    context "with conflicing visits" do
      # Field provider with existing visit that conflicts
      let!(:field_provider) { create(:field_provider, external_id: "S132") }

      it "should find race condition" do
        # Conflicts due to buffer time
        visit.field_provider = field_provider
        result = service.call(visit)
        expect(result.success?).to be false
        expect(result.error).to eq("Visit conflicts with existing visit from 2020-03-22 00:00:00 UTC to 2020-03-22 01:00:00 UTC")

        # Does not conflict due to grace period
        program.update(max_grace_period: 20)
        result = service.call(visit)
        expect(result.success?).to be true
      end
    end
  end
end
