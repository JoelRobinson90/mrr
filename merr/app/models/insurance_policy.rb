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
class InsurancePolicy < ApplicationRecord
  belongs_to :patient
  belongs_to :program

  before_validation :inherit_data_from_patient

  validates :insurance_id_number, presence: true

  def inherit_data_from_patient
    return if patient.blank?

    %i[first_name last_name sex].each do |field_name|
      key = "policy_holder_#{field_name}"
      self[key] = patient[field_name] if self[key].blank?
    end

    self.insurance_id_number = patient.medical_record_number if insurance_id_number.blank?
  end
end
