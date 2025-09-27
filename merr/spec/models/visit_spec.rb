# frozen_string_literal: true

# == Schema Information
#
# Table name: visits
#
#  id                       :bigint           not null, primary key
#  alayacare_status         :string
#  arrival_window_end       :datetime
#  arrival_window_start     :datetime
#  athena_telehealth_url    :string
#  canceled                 :boolean          default(FALSE)
#  confirmed                :boolean          default(FALSE)
#  end_time                 :datetime         not null
#  last_athena_sync         :string
#  push_to_alayacare_error  :string
#  push_to_athena_error     :string
#  reschedule_count         :integer
#  service_instructions     :string
#  start_time               :datetime         not null
#  status                   :string           default("scheduled")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  athena_encounter_id      :integer
#  athena_id                :integer
#  cancel_code_id           :bigint           indexed
#  external_id              :string           not null, indexed
#  field_provider_id        :bigint           indexed
#  ma_id                    :string           indexed
#  next_linked_visit_id     :integer
#  original_visit_id        :integer
#  patient_id               :bigint           not null, indexed
#  previous_linked_visit_id :integer
#  program_id               :bigint           not null, indexed
#  visit_group_id           :integer
#  visit_request_id         :bigint           indexed
#  visit_type_id            :bigint           not null, indexed
#
# Indexes
#
#  index_visits_on_cancel_code_id     (cancel_code_id)
#  index_visits_on_external_id        (external_id) UNIQUE
#  index_visits_on_field_provider_id  (field_provider_id)
#  index_visits_on_ma_id              (ma_id)
#  index_visits_on_patient_id         (patient_id)
#  index_visits_on_program_id         (program_id)
#  index_visits_on_visit_request_id   (visit_request_id)
#  index_visits_on_visit_type_id      (visit_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (cancel_code_id => cancel_codes.id)
#  fk_rails_...  (field_provider_id => field_providers.id)
#  fk_rails_...  (next_linked_visit_id => visits.id)
#  fk_rails_...  (original_visit_id => visits.id)
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (previous_linked_visit_id => visits.id)
#  fk_rails_...  (program_id => programs.id)
#  fk_rails_...  (visit_request_id => visit_requests.id)
#  fk_rails_...  (visit_type_id => visit_types.id)
#
require "rails_helper"

RSpec.describe Visit, type: :model do
  context "with service notes" do
    let(:visit) do
      build(:visit, service_instructions: "local", patient: build(:patient, address: build(:address, notes: "sticky")))
    end

    it "uses address notes if present otherwise local notes" do
      expect(visit.service_instructions).to eq("sticky")

      visit.patient.address.update(notes: nil)

      expect(visit.service_instructions).to eq("local")
    end
  end

  context "when canceled" do
    let(:visit) { build(:visit, canceled: true) }

    it "requries cancel_code" do
      expect(visit.valid?).to be false

      visit.cancel_code = create(:cancel_code)

      expect(visit.valid?).to be true
    end
  end

  context "with visit event" do
    let!(:visit) { create(:visit) }
    let!(:visit_event) { create(:visit_event, visit: visit, event_type: "clocked_in") }

    it "updates status when canceled and uncanceled" do
      expect(visit.status).to eq("scheduled")

      visit.update(canceled: true, cancel_code: create(:cancel_code))

      expect(visit.status).to eq("cancelled")

      visit.update(canceled: false, cancel_code: nil)

      expect(visit.status).to eq("clocked")
    end
  end

  context "before validation" do
    let(:visit) { build(:visit, external_id: nil) }

    it "generates external_id" do
      expect(visit.valid?).to be true

      expect(visit.external_id.length).to eq(5 + 1 + 16) # 5 for visit, 1 for underscore, 16 for hash
      expect(visit.external_id.starts_with?("Visit_")).to be true
    end
  end

  context "with service" do
    let(:visit) { build(:visit) }
    let(:service) { create(:service) }
    let(:another_service) { create(:service) }

    it "detects service changes" do
      expect(visit.services_modified).to be nil

      visit.update(service_ids: [service.id, another_service.id])

      expect(visit.services_modified).to be true

      # reset
      visit.services_modified = nil

      visit.check_for_changed_services([service.id, another_service.id])

      expect(visit.services_modified).to be nil

      visit.check_for_changed_services([5, 7, 13])

      expect(visit.services_modified).to be true
    end
  end

  context "before save" do
    let(:service) { create(:service, alayacare_id: "237") }

    let!(:field_provider) { create(:field_provider, external_id: "S132", athena_id: 4) }
    let!(:different_field_provider) { create(:field_provider, athena_id: 5) }
    let!(:demand_partner) do
      create(:demand_partner, name: "Superior Health Plan")
    end
    let!(:patient) do
      create(:patient, address: build(:address, :florida), athena_id: 4, phone_number: "+17345461234",
medical_record_number: "43klk3sdf0980", sex: "Female", demand_partner: demand_partner)
    end
    let!(:athena_department) do
      create(:athena_department, demand_partner: demand_partner, timezone: patient.address.timezone, athena_id: 3)
    end
    let!(:program) { create(:program) }
    let!(:athena_telehealth_visit_type_id) { 41 } # Standard Hybrid visit
    let!(:visit_type) do
      create(:visit_type, programs: [program], alayacare_id: "6", athena_id: athena_telehealth_visit_type_id,
duration: 30)
    end
    let!(:cancel_code) { create(:cancel_code, code: "PATIENT CANCELLED", athena_id: 13) }

    let!(:custom_patient_field) do
      create(:athena_custom_field, name: "MedArrive Patient ID", athena_id: 44, category: "Patient")
    end
    let!(:custom_appointment_field) do
      create(:athena_custom_field, name: "MedArrive Visit ID", athena_id: 45, category: "Appointment")
    end

    after(:each) do
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "false"
    end

    it "updates on Alayacare" do
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true"

      # make sure cancelation cancel code exists
      Alayacare::PullExternalData.call(CancelCode, "scheduler/cancelcodes", :code)

      visit = build(:visit, program: program, visit_type: visit_type, field_provider: field_provider, patient: patient,
                             start_time: Time.zone.now + 24.hours, end_time: Time.zone.now + 25.hours)

      visit.skip_push_to_athena = true
      visit.save

      expect(visit.persisted?).to be true

      # test updating service codes
      expect(visit.update(service_ids: [service.id])).to be true
      expect(visit.services_modified).to be true
    end

    it "updates on Athena" do
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true"
      # check test setup
      expect(demand_partner.get_athena_department(patient)).to eq(athena_department)

      # WARNING: This has to be in the actual future.
      start_time = "2030-01-20T12:00:00".in_time_zone("America/Los_Angeles")
      end_time = start_time + 1.hour
      program.update(v2: true)
      visit = build(:visit, program: program, visit_type: visit_type, field_provider: field_provider, patient: patient,
                             start_time: start_time, end_time: end_time, push_to_athena_error: "Previous error")

      visit.skip_push_to_alayacare = true
      visit.save
      visit.reload

      expect(visit.persisted?).to be true
      expect(visit.athena_id.present?).to be true
      expect(visit.athena_telehealth_url.present?).to be true
      expect(visit.push_to_athena_error).to be nil
      expect(visit.last_athena_sync.start_with?("Create result:")).to be true
      expect(visit.errors.full_messages.blank?).to be true

      # test no-op change
      old_athena_id = visit.athena_id
      visit.update(service_instructions: "whatever")
      expect(visit.athena_id == old_athena_id).to be true
      expect(visit.errors.full_messages.blank?).to be true

      # test reschedule
      old_athena_id = visit.athena_id
      visit.update(start_time: visit.start_time + 1.hour,
                   end_time:   visit.end_time + 1.hour)
      expect(visit.athena_id.present?).to be true
      expect(visit.athena_id == old_athena_id).to be false
      expect(visit.push_to_athena_error).to be nil
      expect(visit.last_athena_sync.start_with?("Reschedule result:")).to be true
      expect(visit.errors.full_messages.blank?).to be true

      # test provider change
      old_athena_id = visit.athena_id
      visit.update(field_provider: different_field_provider)
      expect(visit.athena_id.present?).to be true
      expect(visit.athena_id == old_athena_id).to be false

      # check in visit
      visit.update(status: "clocked")
      expect(visit.errors.full_messages.blank?).to be true

      # test validations
      # needs to block MA save if visit is checked in
      old_start_time = visit.start_time
      visit.update(start_time: visit.start_time + 10.minutes)
      visit.reload
      expect(visit.start_time == old_start_time).to be true
      err = "Can't reschedule visit after check-in (encounter PEND). Cancel visit and then reschedule."
      expect(visit.errors.full_messages).to eq([err])

      # test cancel
      visit.update(canceled: true, cancel_code: cancel_code)
      expect(visit.athena_id.blank?).to be true
      expect(visit.athena_telehealth_url.blank?).to be true
      expect(visit.errors.full_messages.blank?).to be true
      expect(visit.last_athena_sync.start_with?("Cancel result:")).to be true

      # test undo cancel
      visit.update(canceled: false, cancel_code: nil)
      visit.reload
      expect(visit.athena_id.present?).to be true
      expect(visit.athena_telehealth_url.present?).to be true
      expect(visit.push_to_athena_error).to be nil
      expect(visit.errors.full_messages.blank?).to be true
      expect(visit.last_athena_sync.start_with?("Create result:")).to be true
    end

    it "doesn't update Athena without visit_type athena_id" do
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true"

      visit_type.update(athena_id: nil)
      program.update(v2: true)
      visit = build(:visit, program: program, visit_type: visit_type, field_provider: field_provider, patient: patient,
                             start_time: Time.zone.now + 24.hours, end_time: Time.zone.now + 25.hours)

      visit.skip_push_to_alayacare = true
      visit.save

      expect(visit.persisted?).to be true
      err = "push_to_athena failed: Visit type missing athena_id"
      expect(visit.errors.full_messages.to_sentence).to eq(err)

      visit.reload
      expect(visit.push_to_athena_error).to eq(err)
    end

    it "doesn't update Athena without provider athena_id" do
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true"

      field_provider.update(athena_id: nil)
      program.update(v2: true)
      visit = build(:visit, program: program, visit_type: visit_type, field_provider: field_provider, patient: patient,
                             start_time: Time.zone.now + 24.hours, end_time: Time.zone.now + 25.hours)

      visit.skip_push_to_alayacare = true
      visit.save

      expect(visit.persisted?).to be true
      err = "push_to_athena failed: Field provider missing athena_id"
      expect(visit.errors.full_messages.to_sentence).to eq(err)
    end

    it "doesn't update Athena without v2 program" do
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true"

      visit = build(:visit, program: program, visit_type: visit_type, field_provider: field_provider, patient: patient,
                             start_time: Time.zone.now + 24.hours, end_time: Time.zone.now + 25.hours)

      visit.skip_push_to_alayacare = true
      visit.save

      expect(visit.persisted?).to be true
      expect(visit.athena_id.blank?).to be true
      expect(visit.errors.blank?).to be true
      expect(visit.push_to_athena_error.blank?).to be true
    end

    it "doesn't update Athena if visit_type is outreach_visit" do
      ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true"
      visit_type.outreach_visit = true

      visit = build(:visit, program: program, visit_type: visit_type, field_provider: field_provider, patient: patient,
                             start_time: Time.zone.now + 24.hours, end_time: Time.zone.now + 25.hours)

      visit.skip_push_to_alayacare = true
      visit.save

      expect(visit.persisted?).to be true
      expect(visit.athena_id.blank?).to be true
      expect(visit.errors.blank?).to be true
      expect(visit.push_to_athena_error.blank?).to be true
    end

    it "generates ma_object" do
      visit = create(:visit, program: program, visit_type: visit_type, field_provider: field_provider, patient: patient,
                             start_time: Time.zone.now + 24.hours, end_time: Time.zone.now + 25.hours)

      obj = visit.to_ma_object

      expect(obj[:start_time]).to eq Time.zone.now + 24.hours
      expect(obj[:program][:name]).to eq program.name
      expect(obj[:patient][:first_name]).to eq patient.first_name
      expect(obj[:patient][:city]).to eq patient.address.city
      expect(obj[:patient][:demand_partner][:name]).to eq patient.demand_partner.name
      expect(obj[:field_provider][:phone_number]).to eq field_provider.phone_number
      expect(obj[:field_provider][:email]).to eq field_provider.email
      expect(obj[:field_provider][:field_org][:name]).to eq field_provider.field_org.name
    end
  end

  context "after create" do
    let(:appointment_confirmation) { instance_double(AppointmentConfirmation) }

    before do
      allow(AppointmentConfirmation).to receive(:new).and_return(appointment_confirmation)
      allow(appointment_confirmation).to receive(:call)
    end

    it "send appointment confirmation", :run_delayed_jobs do
      expect(appointment_confirmation).to receive(:call)
      visit = create(:visit)
    end
  end

  context "with multiple resources" do
    let(:field_provider) { create(:field_provider, external_id: "S132", athena_id: 1, role: "field_provider") }
    let(:social_worker) { create(:field_provider, external_id: "j2gjkljf", athena_id: 2, role: "social_worker") }
    let(:nurse_practitioner) do
      create(:field_provider, external_id: "asdflf", athena_id: nil, role: "nurse_practitioner")
    end

    let(:visit) { create(:visit, field_provider: field_provider) }

    let!(:fp_resource) { create(:visit_resource, field_provider: field_provider, visit: visit) }
    let!(:sw_resource) { create(:visit_resource, field_provider: social_worker, visit: visit) }
    let!(:np_resource) { create(:visit_resource, field_provider: nurse_practitioner, visit: visit) }

    it "choses correct Athena id" do
      expect(visit.providers.length).to eq(3)

      expect(visit.get_provider_athena_id).to eq(social_worker.athena_id)

      nurse_practitioner.update(athena_id: 3)
      visit.reload
      expect(visit.get_provider_athena_id).to eq(nurse_practitioner.athena_id)

      # uses default if not multi-resource
      visit.providers.delete_all
      visit.reload
      expect(visit.get_provider_athena_id).to eq(field_provider.athena_id)
    end
  end

  context "after update" do
    let(:appointment_confirmation) { instance_double(AppointmentConfirmation) }
    let(:visit) { create(:visit) }
    let(:visit_with_nil_confirmed) { create(:visit, confirmed: nil) }
    let(:visit_with_window) do
      create(:visit, arrival_window_start: Time.zone.parse("2022-07-11 18:42:11 UTC"),
                     arrival_window_end:   Time.zone.parse("2022-07-11 22:42:11 UTC"))
    end

    before do
      allow(AppointmentConfirmation).to receive(:new).and_return(appointment_confirmation)
      allow(appointment_confirmation).to receive(:call)
    end

    context "without arrival window" do
      it "send appointment confirmation if start time modified", :run_delayed_jobs do
        expect(appointment_confirmation).to receive(:call).twice # once on create + once on update
        visit.start_time = Time.zone.now
        visit.save
      end

      it "does NOT send appointment confirmation if start time is unchanged", :run_delayed_jobs do
        expect(appointment_confirmation).to receive(:call).once # once on create, NOT on update
        visit.service_instructions = "asdf"
        visit.save
      end

      it "resets confirmation if start time modified", :run_delayed_jobs do
        visit.confirmed = true
        visit.save

        visit.start_time = Time.zone.now
        visit.save
        visit.reload
        expect(visit.confirmed).to be false
      end

      it "does NOT reset confirmation if start time is unchanged", :run_delayed_jobs do
        visit.confirmed = true
        visit.save

        visit.service_instructions = "asdf"
        visit.save
        visit.reload
        expect(visit.confirmed).to be true
      end

      it "does NOT reset confirmation if set as part of change", :run_delayed_jobs do
        visit.confirmed = true
        visit.start_time = Time.zone.now
        visit.save
        visit.reload
        expect(visit.confirmed).to be true
      end
    end

    context "with arrival window" do
      it "send appointment confirmation if arrival window start is modified", :run_delayed_jobs do
        expect(appointment_confirmation).to receive(:call).twice # once on create + once on update
        visit_with_window.arrival_window_start = Time.zone.now
        visit_with_window.save
      end

      it "send appointment confirmation if arrival window end is modified", :run_delayed_jobs do
        expect(appointment_confirmation).to receive(:call).twice # once on create + once on update
        visit_with_window.arrival_window_end = Time.zone.now
        visit_with_window.save
      end

      it "resets confirmation if arrival window start is modified", :run_delayed_jobs do
        visit_with_window.confirmed = true
        visit_with_window.save

        visit_with_window.arrival_window_start = Time.zone.now
        visit_with_window.save
        visit_with_window.reload
        expect(visit_with_window.confirmed).to be false
      end

      it "resets confirmation if arrival window end is modified", :run_delayed_jobs do
        visit_with_window.confirmed = true
        visit_with_window.save

        visit_with_window.arrival_window_end = Time.zone.now
        visit_with_window.save
        visit_with_window.reload
        expect(visit_with_window.confirmed).to be false
      end

      it "send appointment confirmation if arrival window end is added", :run_delayed_jobs do
        expect(appointment_confirmation).to receive(:call).twice # once on create + once on update
        visit.arrival_window_start = Time.zone.now
        visit.arrival_window_end = Time.zone.now
        visit.save
      end

      it "does NOT send appointment confirmation if start time modified and arrival window is specified but unchanged",
         :run_delayed_jobs do
        expect(appointment_confirmation).to receive(:call).once # once on create + NOT on update
        # New start time needs to be in the existing window or the window is updated automatically.
        visit_with_window.start_time = visit_with_window.arrival_window_start + 1.minute
        visit_with_window.save
      end

      it "does NOT reset confirmation if start time modified and arrival window is specified but unchanged",
         :run_delayed_jobs do
        visit_with_window.confirmed = true
        visit_with_window.save

        visit_with_window.start_time = visit_with_window.arrival_window_start + 1.minute
        visit_with_window.save
        visit_with_window.reload
        expect(visit_with_window.confirmed).to be true
      end

      it "does NOT send appointment confirmation if window is unchanged", :run_delayed_jobs do
        expect(appointment_confirmation).to receive(:call).once # once on create, NOT on update
        visit_with_window.service_instructions = "asdf"
        visit_with_window.save
      end
    end

    context "with nil confirmed" do
      it "sets confirmation to false if currently nil", :run_delayed_jobs do
        expect(visit_with_nil_confirmed.confirmed).to be nil
        visit_with_nil_confirmed.save
        visit_with_nil_confirmed.reload
        expect(visit_with_nil_confirmed.confirmed).to be false
      end

      it "doesn't override confirmation to false if being set true", :run_delayed_jobs do
        expect(visit_with_nil_confirmed.confirmed).to be nil
        visit_with_nil_confirmed.confirmed = true
        visit_with_nil_confirmed.save
        visit_with_nil_confirmed.reload
        expect(visit_with_nil_confirmed.confirmed).to be true
      end
    end
  end
end
