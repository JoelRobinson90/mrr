# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::RescheduleCancelledVisit, type: :request do
  let(:service) { described_class }
  let!(:patient) { FactoryBot.create(:patient, medical_record_number: "3645624t56") }
  let(:start_time) { Time.zone.now }
  let(:end_time) { Time.zone.now + 1.hour }
  let(:field_provider) { create(:field_provider) }
  let(:date_time_format) { "%Y-%m-%d %H:%M" }
  let(:cancel_code) { build(:cancel_code) }
  let(:resources) do
    [{
      resource_id: field_provider.external_id,
      start_time:  start_time,
      end_time:    end_time,
      in_home:     true
    }]
  end

  context "rescheduling a non cancelled visit" do
    let(:visit) { create(:visit, patient: patient) }
    it "should not proceed with the rescheduling flow" do
      response = service.call(visit: visit, start_time: start_time, end_time: end_time,
                              field_provider: field_provider, resources: resources)
      expect(response).to be_present
      expect(response.success?).to be false
      expect(response.error).to eql "visit must be cancelled"
    end
  end

  context "rescheduling a cancelled v1 visit" do
    let(:visit) { create(:visit, patient: patient, canceled: true, cancel_code: cancel_code, status: "cancelled") }

    before do
      expect(::Alayacare::CheckRaceCondition).to receive(:call).at_least(:once).and_return(OpenStruct.new({success?: true}))
    end

    it "should create a new visit" do
      response = nil

      expect do
        response = service.call(visit: visit, start_time: start_time, end_time: end_time,
                                field_provider: field_provider, resources: resources)
      end.to change { VisitResource.count }.by(1)

      expect(response.success?).to be true
      expect(response.payload).to be_present

      new_visit = response.payload

      # original visit still there
      visit.reload
      expect(visit.field_provider != field_provider).to be true
      expect(visit.canceled).to be true

      # id fields are reset
      expect(visit.id != new_visit.id).to be true
      expect(visit.external_id != new_visit.external_id).to be true
      expect(visit.ma_id != new_visit.ma_id).to be true

      # new visit should not be cancelled
      expect(new_visit.canceled).to be false
      expect(new_visit.status).to eq("scheduled")
      # new visit should have the same fields than original visit
      expect(new_visit.patient_id).to eq(patient.id)
      expect(new_visit.program_id).to eq(visit.program_id)
      # new visit should have new scheduled date time and field provider
      expect(new_visit.start_time.strftime(date_time_format)).to eq(start_time.strftime(date_time_format))
      expect(new_visit.end_time.strftime(date_time_format)).to eq(end_time.strftime(date_time_format))
      expect(new_visit.field_provider).to eq(field_provider)

      new_resource = new_visit.visit_resources.first
      expect(new_resource.field_provider).to eq(field_provider)
      expect(new_resource.start_time).to eq(start_time)
      expect(new_resource.end_time).to eq(end_time)
      expect(new_resource.in_home).to eq(true)

      # should update new_visit.original_visit
      expect(new_visit.original_visit).to eq(visit)

      # should update reschedule_count
      expect(new_visit.reschedule_count).to eq(1)
    end
  end

  context "rescheduling a cancelled v2 visit" do
    let(:program) { create(:program, v2: true) }
    let(:visit) { create(:visit, patient: patient, canceled: true, confirmed: true, cancel_code: cancel_code, program: program, status: "cancelled") }

    it "should create a new visit" do
      response = nil

      expect do
        response = service.call(visit: visit, start_time: start_time, end_time: end_time,
                                field_provider: field_provider, resources: resources)
      end.to change { VisitResource.count }.by(1)

      expect(response.success?).to be true
      expect(response.payload).to be_present

      new_visit = response.payload

      # original visit still there
      visit.reload
      expect(visit.field_provider != field_provider).to be true
      expect(visit.canceled).to be true

      # id fields are reset
      expect(visit.id != new_visit.id).to be true
      expect(visit.external_id != new_visit.external_id).to be true
      expect(visit.ma_id != new_visit.ma_id).to be true

      # new visit should not be cancelled
      expect(new_visit.canceled).to be false
      expect(new_visit.status).to eq("scheduled")
      # new visit should not be confirmed
      expect(new_visit.confirmed).to be false
      # new visit should have the same fields than original visit
      expect(new_visit.patient_id).to eq(patient.id)
      expect(new_visit.program_id).to eq(visit.program_id)
      # new visit should have new scheduled date time and field provider
      expect(new_visit.start_time.strftime(date_time_format)).to eq(start_time.strftime(date_time_format))
      expect(new_visit.end_time.strftime(date_time_format)).to eq(end_time.strftime(date_time_format))
      expect(new_visit.field_provider).to eq(field_provider)

      new_resource = new_visit.visit_resources.first
      expect(new_resource.field_provider).to eq(field_provider)
      expect(new_resource.start_time).to eq(start_time)
      expect(new_resource.end_time).to eq(end_time)
      expect(new_resource.in_home).to eq(true)

      # should update new_visit.original_visit
      expect(new_visit.original_visit).to eq(visit)

      # should update reschedule_count
      expect(new_visit.reschedule_count).to eq(1)
    end
  end
end
