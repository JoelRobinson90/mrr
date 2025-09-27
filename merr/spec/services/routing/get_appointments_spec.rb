# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::GetAppointments, type: :request do
  let(:service) { Routing::GetAppointments }

  context "with start and end date" do
    let(:target_date) { Date.parse("2021-11-01") }

    # NOTE: matches patient ID in VCR response
    let!(:patient) { FactoryBot.create(:patient, medical_record_number: "3645624t56") }

    it "fetches appointments and adds patient locations" do
      result = service.call(target_date, target_date)

      expect(result.success?).to be true
      expect(result.payload).to have(5).item

      # check without filtering canceled visits
      result = service.call(target_date, target_date, filter_canceled = false)
      expect(result.payload).to have(6).item

      expected = AlayacareApiVisit.new(
        id:                 645,
        alayacare_visit_id: 645,
        fp_id:              "1227",
        location:           "47.65373,-122.32868",
        start_time:         Time.zone.parse("2021-11-01 22:00:00.000000000 +0000"),
        end_time:           Time.zone.parse("2021-11-01 23:30:00.000000000 +0000"),
        demand_partner_id:  patient&.demand_partner_id,
        demand_partner:     patient.demand_partner.to_builder.attributes!,
        patient:            patient,
        status:             "cancelled",
        client_id:          "3645624t56",
        cx_end:             Time.zone.parse("2021-11-01 23:30:00.000000000 +0000"),
        cx_start:           Time.zone.parse("2021-11-01 22:00:00.000000000 +0000"),
        fp_name:            "Baylee FP",
        notes:              [],
        cancelled:          true,
        cancel_code:        {"code" => "Patient Reported COVID Exposure",
"description" => "Patient cancelled because of a possible case of COVID or COVID exposure, and should be called later for a reschedule", "id" => 6}
      )

      expect(result.payload.select {|v| v.alayacare_visit_id == 645 }[0].to_h).to eq(expected.to_h)
    end

    context "with pagination" do
      let(:visits_per_page) { 2 }

      it "fetches multiple pages" do
        result = service.call(target_date, target_date, visits_per_page: visits_per_page)

        expect(result.success?).to be true
        # Actual visit returned is third result
        expect(result.payload.length).to eq(6)
      end
    end
  end
end
