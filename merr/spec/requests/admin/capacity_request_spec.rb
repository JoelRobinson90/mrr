# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Capacity", type: :request do
  let!(:current_user) { create(:medarrive_admin).user }

  before do
    sign_in current_user
  end

  describe "availability with real visits" do
    let!(:visit) { create(:visit) }

    it "successfully renders the react CapacityComponent" do
      Timecop.freeze(visit.start_time) do
        get admin_capacity_availability_path
        expect(response).to render_template("layouts/admin")
      end
    end
  end

  describe "availability with mocked visits" do
    let(:now) { Time.zone.now }
    let(:first_visit_start_date) { now + 3.hours }
    let(:first_visit_end_date) { first_visit_start_date + 30.minutes }
    let(:second_visit_start_date) { first_visit_start_date + 30.minutes }
    let(:second_visit_end_date) { second_visit_start_date + 30.minutes }
    let(:drive_time_minutes) { 5 }
    let(:visits) do
      [
        AlayacareApiVisit.new(
          alayacare_visit_id: 1215,
          fp_id:              "8055",
          location:           "29.803413,-95.325936",
          start_time:         first_visit_start_date,
          end_time:           first_visit_end_date,
          drive_time:         drive_time_minutes
        ),
        AlayacareApiVisit.new(
          alayacare_visit_id: 1215,
          fp_id:              "45540",
          location:           "29.803413,-95.325936",
          start_time:         second_visit_start_date,
          end_time:           second_visit_end_date,
          drive_time:         drive_time_minutes
        )
      ]
    end
    let(:shifts) do
      [
        {
          fp_id:      "8055",
          start_time: Time.zone.now.beginning_of_day,
          end_time:   Time.zone.now.end_of_day,
          fp_name:    "Baylee Texas",
          groups:     ["Molina"],
          location:   "29.76018,-95.36935"
        },
        {
          fp_id:      "45540",
          start_time: Time.zone.now.beginning_of_day,
          end_time:   Time.zone.now.end_of_day,
          fp_name:    "Houston TX FP",
          groups:     ["Molina"],
          location:   "30.05011,-95.47703"
        },
        {
          fp_id:      "13244",
          start_time: Time.zone.now.beginning_of_day,
          end_time:   Time.zone.now.end_of_day,
          fp_name:    "Centene FP",
          groups:     ["Centene - Health Net"],
          location:   "34.0518,-118.251994"
        }
      ]
    end
    let(:start_date) { Date.today }
    let(:end_date) { start_date.end_of_day }

    before do
      allow(Routing::GetShifts).to receive(:call) do
        OpenStruct.new(success?: true, payload: shifts)
      end
      allow(Routing::GetVisits).to receive(:call) do
        OpenStruct.new(success?: true, payload: visits)
      end
      allow(Routing::AddRetroactiveDriveTime).to receive(:call) do
        OpenStruct.new(success?: true, payload: visits)
      end
    end

    it "successfully returns a valid json" do
      get admin_capacity_get_availability_by_date_path(start_date: start_date, end_date: end_date, include_shifts: true)
      body = JSON.parse response.body
      expect(body["shifts"]).to be_present
      expect(body["visits"]).to be_present

      expect(body["shifts"].length).to eq 3
      expect(body["visits"].length).to eq 2
      expect(Routing::GetShifts).to have_received(:call).with(start_date, end_date, include_users: true)
      expect(Routing::GetVisits).to have_received(:call).with(start_date, end_date, false, patient: nil)
    end

    it "generates drive times" do
      get admin_capacity_get_availability_by_date_path(start_date: start_date, end_date: end_date)
      body = JSON.parse response.body
      expect(Routing::AddRetroactiveDriveTime).to have_received(:call).with(visits)
    end
  end
end
