# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: patients
#
#  id                             :bigint           not null, primary key
#  consent_to_email               :boolean          default(FALSE), not null
#  consent_to_text                :boolean          default(FALSE), not null
#  contact_email                  :string
#  date_of_birth                  :date
#  emergency_contact_name         :string
#  emergency_contact_phone_number :string
#  ethnicity                      :string
#  first_name                     :string
#  gender                         :string
#  last_name                      :string
#  medical_record_number          :string
#  middle_initial                 :string
#  needs_hra_survey               :boolean
#  patient_notes                  :text
#  phone_number                   :string
#  phone_number_type              :string
#  preferred_contact_method       :string
#  preferred_language             :string
#  preferred_pronouns             :string
#  primary_risk_category          :string
#  push_to_athena_error           :string
#  race                           :string
#  region                         :string
#  secondary_phone_number         :string
#  secondary_phone_number_type    :string
#  sex                            :string
#  status                         :string           default("Created"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  athena_id                      :integer
#  datalake_id                    :string
#  demand_partner_id              :bigint           not null, indexed
#  external_id                    :string           not null, indexed
#  ma_id                          :string           indexed
#  primary_care_physician_id      :bigint           indexed
#
# Indexes
#
#  index_patients_on_demand_partner_id          (demand_partner_id)
#  index_patients_on_external_id                (external_id) UNIQUE
#  index_patients_on_ma_id                      (ma_id)
#  index_patients_on_primary_care_physician_id  (primary_care_physician_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#  fk_rails_...  (primary_care_physician_id => primary_care_physicians.id)
#
require "rails_helper"

RSpec.describe Patient, type: :model do
  let(:patient) { create(:patient, :with_address) }

  # TODO: move this to a shared context for other MA ID models
  before do
    allow(Lambdaforce::PushRecord).to receive(:call) do
      OpenStruct.new(success?: true)
    end
  end

  describe "ma_object generation" do
    it "includes address and demand partner" do
      obj = patient.to_ma_object

      expect(obj[:ma_id]).to eq(patient.ma_id)
      expect(obj[:first_name]).to eq(patient.first_name)
      expect(obj[:address_line_one]).to eq(patient.address.address_line_one)
      expect(obj[:demand_partner][:name]).to eq(patient.demand_partner.name)
    end
  end

  describe "callbacks" do
    describe "update_alayacare_client" do
      before do
        allow(Alayacare::ClientCreateOrUpdateService).to receive(:call).and_return(OpenStruct.new(success?: true))
      end

      describe "after create and after update" do
        let(:patient) { create(:patient, :with_address, 
                                         update_alayacare_in_foreground: true,
                                         programs: [build(:program, v2: false)]) }

        it "creates or updates the AlayaCare client" do
          patient.save!
          expect(Alayacare::ClientCreateOrUpdateService).to have_received(:call).with(patient, ["all"]).twice
        end
      end
    end

    describe "update Athena patient on save" do
      before do
        ENV["ENABLE_PUSH_TO_EXTERNAL"] = "true"
        allow(Athena::PushPatient).to receive(:call).and_return(OpenStruct.new(success?: true))
      end

      after do
        ENV["ENABLE_PUSH_TO_EXTERNAL"] = "false"
      end

      describe "after update" do
        let(:patient) { create(:patient, :with_address, skip_push_to_alayacare: true) }

        it "doesn't send to athena without existing id" do
          patient.save!
          expect(Athena::PushPatient).not_to have_received(:call)
        end

        it "sends to athena if it has an athena_id" do
          patient.update(athena_id: 999)
          expect(Athena::PushPatient).to have_received(:call).with(patient, nil)
        end
      end
    end

    describe "update_alayacare_client async" do
      before do
        allow(CreateOrUpdateAlayacareClientJob).to receive(:perform_later)
      end

      describe "after create and after update" do
        let(:patient) { create(:patient, update_alayacare_in_foreground: false, 
                                         programs: [build(:program, v2: false)]) }

        it "creates or updates the AlayaCare client" do
          patient.save!
          expect(CreateOrUpdateAlayacareClientJob).to have_received(:perform_later).with(patient).twice
        end
      end
    end

    describe "with v2 programs only" do
      before do
        allow(CreateOrUpdateAlayacareClientJob).to receive(:perform_later)
      end
      
      describe "doesn't update Alayacare" do
        let(:patient) { create :patient, programs: [build(:program, v2: true)] }

        it "creates or updates the AlayaCare client" do
          patient.save!
          expect(CreateOrUpdateAlayacareClientJob).to_not have_received(:perform_later)
        end
      end
    end

    describe "with v2 program and inactive v1 program only" do
      before do
        allow(CreateOrUpdateAlayacareClientJob).to receive(:perform_later)
      end
      
      describe "doesn't update Alayacare" do
        let(:patient) { create :patient, programs: [build(:program, v2: true), build(:program, v2: false, active: false)] }

        it "creates or updates the AlayaCare client" do
          patient.save!
          expect(CreateOrUpdateAlayacareClientJob).to_not have_received(:perform_later)
        end
      end
    end

    context "with ma_id" do
      let(:patient) { build(:patient) }

      it "saves new ma_id" do
        patient.save

        components = patient.ma_id.split("_")

        expect(components[0]).to eq "spec"
        expect(components[1]).to eq "Patient"

        next_id = components[2].to_i + 1

        second_patient = build(:patient, status: nil)

        begin
          # fails to save due to DB "not nil" constraint
          # but uses up next id in the sequence
          # (This won't happen if normal validations fail)
          second_patient.save(skip_validations: true)
        rescue StandardError => e
        end
        expect(second_patient.id).to be nil
        expect(second_patient.ma_id).to eq "spec_Patient_#{next_id}"

        # another patient created in the meantime
        # This uses up "next_id + 1"
        third_patient = create(:patient)
        expect(third_patient.ma_id).to eq("spec_Patient_#{next_id + 1}")

        # fix DB error and re-save
        second_patient.status = "Created"
        second_patient.save

        # original next_id is still safe to use because
        # the DB reserved it already.
        expect(second_patient.ma_id).to eq "spec_Patient_#{next_id}"
      end

      context "without prefix" do
        before do
          ENV["MA_ID_PREFIX"] = nil
        end

        after do
          ENV["MA_ID_PREFIX"] = "spec"
        end

        it "saves ma_id" do
          patient = create(:patient)

          components = patient.ma_id.split("_")
          expect(components[0].length).to eq 7
          expect(components[0].starts_with?("dev")).to be true
        end
      end

      context "with salesforce feature flag on" do
        let(:v2_program) { create :program, v2: true }
        let(:v1_program) { create :program, v2: false }

        before do
          Flipper.enable(:push_to_salesforce)
        end

        after do
          Flipper.disable(:push_to_salesforce)
        end

        context "patient without programs" do
          let(:patient) { build :patient, programs: [] }

          it "is not pushed to salesforce" do
            patient.save!
            expect(Lambdaforce::PushRecord).to_not have_received(:call)
          end
        end

        context "patient with only v1 programs" do
          let(:patient) { build :patient, programs: [v1_program] }

          it "is not pushed to salesforce" do
            patient.save!
            expect(Lambdaforce::PushRecord).to_not have_received(:call)
          end
        end

        context "patient with a v2 program" do
          let(:patient) { build :patient, programs: [v2_program] }

          it "is pushed to salesforce along with its program" do
            patient.save!
            expect(Lambdaforce::PushRecord).to have_received(:call).exactly(2).times

            expect(Lambdaforce::PushRecord).to have_received(:call).with(
              hash_including(ma_id: patient.ma_id, payload_type: "Patient")
            )
            expect(Lambdaforce::PushRecord).to have_received(:call).with(
              hash_including(
                ma_id:        patient.patient_programs.last.ma_id,
                payload_type: "PatientProgram",
                payload:      hash_including(
                  patient: hash_including(
                    ma_id: patient.ma_id
                  ),
                  program: hash_including(
                    ma_id: v2_program.ma_id
                  )
                )
              )
            )
          end

          it "is not pushed if skip flag is true" do
            patient.skip_push_to_salesforce = true
            patient.save!
            expect(Lambdaforce::PushRecord).not_to have_received(:call).with(
              hash_including(payload_type: "Patient")
            )
          end
        end
      end
    end
  end

  it "should be searchable by first_name, last_name, full name, and medical record number" do
    expect(Patient.search(patient.first_name).map(&:id)).to include(patient.id)
    expect(Patient.search(patient.last_name).map(&:id)).to include(patient.id)
    expect(Patient.search("#{patient.first_name} #{patient.last_name}").map(&:id)).to include(patient.id)
    expect(Patient.search(patient.medical_record_number).map(&:id)).to include(patient.id)
  end

  it "should be searchable by Address fields [address_line_one address_line_two city state]" do
    expect(Patient.search(patient.address.address_line_one).map(&:id)).to include(patient.id)
    expect(Patient.search(patient.address.address_line_two).map(&:id)).to include(patient.id)
    expect(Patient.search(patient.address.city).map(&:id)).to include(patient.id)
    expect(Patient.search(patient.address.state).map(&:id)).to include(patient.id)
  end

  it "should provide gender an sex" do
    expect(Patient::SEXES).to include(patient.sex)
  end

  it "should verify sex exists in the listed set" do
    patient.sex = Faker::Lorem.word

    expect(patient.valid?).to be false
  end

  it "allows for association of address" do
    patient.address = build(:address)
    expect(patient).to be_valid
  end

  it "should format phone number" do
    patient.update(phone_number: "(111) 555-3333")

    expect(patient.phone_number).to eq("+11115553333")
  end

  it "should strip whitespace from region" do
    patient.update(region: " test ")

    expect(patient.region).to eq("test")
  end

  context "with multiple preferred providers" do

    let(:fp1) { create(:field_provider) }
    let(:fp2) { create(:field_provider) }
    let(:np1) { create(:field_provider, role: "nurse_practitioner") }

    let!(:pref1) { create(:provider_preference, patient: patient, field_provider: fp1) }
    let!(:pref2) { create(:provider_preference, patient: patient, field_provider: fp2, created_at: Time.now - 1.day) }
    let!(:pref3) { create(:provider_preference, patient: patient, field_provider: np1) }

    it "should return latest preferred provider for each role" do
      expect(patient.preferred_providers_one_per_role).to match_array([fp1, np1])
    end
  end
end
