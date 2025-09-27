# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::GetAppointmentsByPatient, type: :request do
  let(:service) { Routing::GetAppointmentsByPatient }

  context "with patient" do
    # NOTE: matches patient ID in VCR response
    let!(:patient) { FactoryBot.create(:patient, medical_record_number: "3645624t56") }

    # NOTE: based on cached VCR response
    let(:expected_visit) do
      AlayacareApiVisit.new(
        alayacare_visit_id: 645,
        visit_id:           nil,
        id:                 645,
        fp_name:            "Baylee FP",
        fp_id:              "AC000001227",
        start_time:         Time.zone.parse("2021-11-01 22:00:00.000000000 +0000"),
        end_time:           Time.zone.parse("2021-11-01 23:30:00.000000000 +0000"),
        cancelled:          false,
        cx_start:           Time.zone.parse("2021-11-01 22:00:00.000000000 +0000"),
        cx_end:             Time.zone.parse("2021-11-01 23:30:00.000000000 +0000"),
        notes:              [],
        local:              false,
        services:           nil,
        service_instructions: nil,
        location:           nil,
        status:            "missed",
        client_id:         "3645624t56"
      )
    end

    it "fetches appointments and field provider names" do
      result = service.call(patient)

      expect(result.success?).to be true

      expect(result.payload.map{|r| r.to_h}).to eq([expected_visit.to_h])
    end

    context "with pagination" do
      let(:visits_per_page) { 2 }

      it "fetches multiple pages" do
        result = service.call(patient, visits_per_page: visits_per_page)

        expect(result.success?).to be true
        expect(result.payload.length).to eq(1)
      end
    end
  end
end
