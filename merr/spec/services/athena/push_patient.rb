# typed: true
# frozen_string_literal: true

require "rails_helper"

custom_vcr = {match_requests_on: :path}

RSpec.describe Athena::PushPatient, type: :request do
  let(:service) { Athena::PushPatient }

  let!(:demand_partner) do
    create(:demand_partner, name: "Superior Health Plan")
  end

  let!(:athena_department) do
    create(:athena_department, name: "Superior Health Plan", demand_partner: demand_partner, athena_id: 3,
                               timezone: "America/Chicago")
  end

  let(:program) { create(:program) }
  let!(:patient) do
    create(:patient, address: build(:address), phone_number: "+17345461234", medical_record_number: "sf34r34f",
                     sex: "Female", demand_partner: demand_partner, programs: [program],
                     preferred_language: "English", contact_email: "test@patient.com")
  end

  it "doesn't find athena_id for new patient", vcr: custom_vcr do
    instance = service.new(patient, program)
    expect(instance.find_existing_athena_id).to be nil
  end

  it "Pushes new patient", vcr: custom_vcr do
    result = service.call(patient, program)
    expect(result.success?).to be true
  end

  it "sends default insurance policy info" do
    instance = service.new(patient, program)

    expected = {
      insuranceidnumber:              patient.medical_record_number,
      insurancepackageid:             0,
      insurancepolicyholderfirstname: patient.first_name,
      insurancepolicyholderlastname:  patient.last_name,
      insurancepolicyholdersex:       patient.sex[0], # Just first letter
      insuredentitytypeid:            1,
      relationshiptoinsuredid:        1,
      sequencenumber:                 1
    }

    expect(instance.insurance_body).to eq(expected)
  end

  describe "with existing insurance policy" do
    let(:previous_insurance_policy) { create(:insurance_policy, patient: patient, program: program) }
    let(:insurance_policy) do
      create(:insurance_policy, patient: patient, program: program, policy_holder_first_name: "p_first",
                                policy_holder_last_name: "p_last", policy_holder_sex: "Female",
                                insurance_id_number: "1", insurance_package_id: "555",
                                insurance_sequence_number: 2, relationship_to_insured_id: 2)
    end
    let(:different_program_insurance_policy) { create(:insurance_policy, patient: patient) }

    it "sends info from latest insurance policy on program" do
      instance = service.new(patient, program)

      expected = {
        insuranceidnumber:              insurance_policy.insurance_id_number,
        insurancepackageid:             insurance_policy.insurance_package_id,
        insurancepolicyholderfirstname: insurance_policy.policy_holder_first_name,
        insurancepolicyholderlastname:  insurance_policy.policy_holder_last_name,
        insurancepolicyholdersex:       insurance_policy.policy_holder_sex[0], # Just first letter
        insuredentitytypeid:            1,
        relationshiptoinsuredid:        insurance_policy.relationship_to_insured_id,
        sequencenumber:                 insurance_policy.insurance_sequence_number
      }

      expect(instance.insurance_body).to eq(expected)
    end
  end
end
