# frozen_string_literal: true

# == Schema Information
#
# Table name: insurance_policies
#
#  id                         :bigint           not null, primary key
#  insurance_id_number        :string           not null
#  insurance_sequence_number  :integer          default(1), not null
#  policy_holder_first_name   :string
#  policy_holder_last_name    :string
#  policy_holder_sex          :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  insurance_package_id       :integer          default(0), not null
#  patient_id                 :bigint           not null, indexed
#  program_id                 :bigint           not null, indexed
#  relationship_to_insured_id :integer          default(1), not null
#
# Indexes
#
#  index_insurance_policies_on_patient_id  (patient_id)
#  index_insurance_policies_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#
require "rails_helper"

RSpec.describe InsurancePolicy, type: :model do
  let(:patient) do
    create(:patient, first_name: "test_first", last_name: "test_last", sex: "Female", medical_record_number: "MRN")
  end

  let(:blank_policy) do
    create(:insurance_policy, patient: patient, policy_holder_first_name: "", policy_holder_last_name: "",
                              policy_holder_sex: "", insurance_id_number: "")
  end
  let(:initialized_policy) do
    create(:insurance_policy, patient: patient, policy_holder_first_name: "p_first", policy_holder_last_name: "p_last",
                              policy_holder_sex: "Male", insurance_id_number: "1")
  end

  it "inherits data from patient if not initialized" do
    expect(blank_policy.policy_holder_first_name).to eq(patient.first_name)
    expect(blank_policy.policy_holder_last_name).to eq(patient.last_name)
    expect(blank_policy.policy_holder_sex).to eq(patient.sex)
    expect(blank_policy.insurance_id_number).to eq(patient.medical_record_number)

    expect(initialized_policy.policy_holder_first_name).not_to eq(patient.first_name)
    expect(initialized_policy.policy_holder_last_name).not_to eq(patient.last_name)
    expect(initialized_policy.policy_holder_sex).not_to eq(patient.sex)
    expect(initialized_policy.insurance_id_number).not_to eq(patient.medical_record_number)
  end
end
