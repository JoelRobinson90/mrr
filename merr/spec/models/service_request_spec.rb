# frozen_string_literal: true

# == Schema Information
#
# Table name: service_requests
#
#  id             :bigint           not null, primary key
#  refusal_reason :string
#  status         :string           default("requested"), not null
#  status_detail  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  ma_id          :string           not null, indexed
#  patient_id     :bigint           not null, indexed => [program_id, service_id]
#  program_id     :bigint           not null, indexed, indexed => [patient_id, service_id]
#  service_id     :bigint           not null, indexed, indexed => [patient_id, program_id]
#
# Indexes
#
#  index_service_requests_on_ma_id        (ma_id)
#  index_service_requests_on_program_id   (program_id)
#  index_service_requests_on_service_id   (service_id)
#  patient_program_service_request_index  (patient_id,program_id,service_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#  fk_rails_...  (service_id => services.id)
#
require "rails_helper"

RSpec.describe ServiceRequest, type: :model do
  let(:demand_partner) { create :demand_partner }
  let(:program) { create :program, demand_partner: demand_partner }
  let(:service) { create :service }
  let(:patient) { create :patient, demand_partner: demand_partner, programs: [program] }
  let(:service_request) do
    create :service_request, service: service, patient: patient, program: program, status: "scheduled",
   status_detail: "detail", refusal_reason: "none"
  end
  let(:patient_program) { patient.patient_programs.first }

  describe "to_ma_object" do
    it "contains service name and patient program" do
      ma_object = service_request.to_ma_object
      expect(ma_object).to include({
                                     ma_id:          service_request.ma_id,
                                     status:         "scheduled",
                                     status_detail:  "detail",
                                     refusal_reason: "none"
                                   })

      expect(ma_object[:patient_program]).to include({
                                                       ma_id: patient_program.ma_id
                                                     })
    end
  end

  describe "with associated visits" do
    let!(:visit1) { create(:visit, patient: patient, program: program, services: [service]) }
    let!(:visit2) { create(:visit, patient: patient, services: [service]) } # different program
    let!(:visit3) { create(:visit, program: program, services: [service]) } # different patient

    it "Only links to visits with the same patient and program" do
      expect(service_request.covering_visits).to eq([visit1])
    end
  end

  context "with callbacks" do
    let(:service1) { create(:service) }
    let(:service2) { create(:service) }
    let(:service3) { create(:service) }

    let(:program) { create(:program) }
    let(:patient) { create(:patient) }

    let!(:visit1) { create(:visit, patient: patient, program: program, services: [service1, service2]) }
    let!(:visit2) { create(:visit, patient: patient, program: program, services: [service1]) }

    let(:service_request1) { create(:service_request, service: service1, patient: patient, program: program) }
    let(:service_request2) { create(:service_request, service: service2, patient: patient, program: program) }
    let(:service_request3) { create(:service_request, service: service3, patient: patient, program: program) }

    # This one has a different program and should be ignored
    let!(:service_request4) { create(:service_request, service: service1, patient: patient) }

    it "detects removed service after refresh" do
      service_request2.refresh_status
      expect(service_request2.status).to eq("in-progress")

      # This doesn't run any hooks
      visit1.visit_services.delete_all

      # Even though this runs hooks, this visit is no longer
      # connected to any services.  May try and fix in the future
      # but for now we need a refresh.
      visit1.save
      service_request2.reload
      expect(service_request2.status).to eq("in-progress")

      expect(service_request2.refresh_status).to eq("requested")
      expect(service_request2.status).to eq("requested")
    end

    it "updates service request status on visit update" do

      expect(service_request1.status).to eq("requested")
      expect(service_request2.status).to eq("requested")
      expect(service_request3.status).to eq("requested")

      expect(service_request1.covering_visits).to eq([visit1, visit2])
      expect(service_request2.covering_visits).to eq([visit1])
      expect(service_request3.covering_visits).to eq([])

      expect(visit1.covered_service_requests).to eq([service_request1, service_request2])
      expect(visit2.covered_service_requests).to eq([service_request1])

      visit1.save

      service_request1.reload
      service_request2.reload
      service_request3.reload
      service_request4.reload

      expect(service_request1.status).to eq("in-progress") # updated by visit1
      expect(service_request2.status).to eq("in-progress") # updated by visit1
      expect(service_request3.status).to eq("requested")
      expect(service_request4.status).to eq("requested")

      visit1.update(canceled: true, cancel_code: build(:cancel_code))

      service_request1.reload
      service_request2.reload
      service_request3.reload
      service_request4.reload

      expect(service_request1.status).to eq("in-progress") # protected by visit2
      expect(service_request2.status).to eq("requested") # reset by visit1
      expect(service_request3.status).to eq("requested")
      expect(service_request4.status).to eq("requested")

      # Don't overwrite unknown statuses
      service_request2.update(status: "some-terminal-state")
      visit1.save
      service_request2.reload
      expect(service_request2.status).to eq("some-terminal-state")

      # Updates status even if a different visit was updated without hooks
      visit2.visit_services.delete_all
      visit1.save
      service_request1.reload
      expect(service_request1.status).to eq("requested")
    end
  end
end
