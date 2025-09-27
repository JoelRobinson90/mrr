# == Schema Information
#
# Table name: patient_programs
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ma_id      :string           indexed
#  patient_id :bigint           indexed => [program_id], indexed => [program_id]
#  program_id :bigint           indexed => [patient_id], indexed => [patient_id]
#
# Indexes
#
#  index_patient_programs_on_ma_id                      (ma_id)
#  index_patient_programs_on_patient_id_and_program_id  (patient_id,program_id)
#  index_patient_programs_on_program_id_and_patient_id  (program_id,patient_id)
#
require "rails_helper"

RSpec.describe PatientProgram do
  let(:demand_partner) { create :demand_partner }
  let(:patient) { create :patient, demand_partner: demand_partner, ma_id: "spec_Patient_12" }
  let(:program) { create :program, demand_partner: demand_partner, ma_id: "spec_Program_13" }
  let(:patient_program) { PatientProgram.create(patient: patient, program: program) }

  describe "validations" do
    describe "patient_ma_id_must_exist for v2 program" do
      context "patient has no ma_id" do
        before do
          patient.update_column(:ma_id, nil)
          program.update_column(:v2, true)
        end

        it "is invalid" do
          expect(patient_program).not_to be_valid
          expect(patient_program.ma_id).to be nil
        end
      end

      context "program has no ma_id" do
        before do
          program.update_column(:ma_id, nil)
          program.update_column(:v2, true)
        end

        it "is invalid" do
          expect(patient_program).not_to be_valid
          expect(patient_program.ma_id).to be nil
        end
      end

      context "patient and program has ma_id" do
        it "creates ma_id from patient and program ma_ids" do
          expect(patient_program).to be_valid
          expect(patient_program.ma_id).to eq "spec_PatientProgram_12|13"
        end
      end
    end

    describe "patient_ma_id_must_exist for v1 program" do
      context "patient has no ma_id" do
        before do
          patient.update_column(:ma_id, nil)
        end

        it "is okay" do
          expect(patient_program).to be_valid
        end
      end
    end
  end

  describe "to_ma_object" do
    it "contains patient and program associations" do
      ma_object = patient_program.to_ma_object

      expect(ma_object[:ma_id]).to be_present
      expect(ma_object[:ma_id]).to eq patient_program.ma_id
      expect(ma_object[:patient]).to include(ma_id: patient.ma_id)
      expect(ma_object[:program]).to include(ma_id: program.ma_id)
    end
  end

  describe "Lambdaforce payload" do
    it "uses patient ma_id for its message group id" do
      sf_body = patient_program.salesforce_push_body
      expect(sf_body[:message_group]).to eq patient.ma_id
    end
  end
end