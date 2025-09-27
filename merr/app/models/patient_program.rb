# frozen_string_literal: true

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
class PatientProgram < ApplicationRecord
  include PushToSalesforce

  belongs_to :program, optional: false, inverse_of: :patient_programs
  belongs_to :patient, optional: false, inverse_of: :patient_programs

  validate :patient_and_program_ma_id_must_exist, on: :create

  attr_accessor :crm_custom_fields, :status, :status_date, :dismissal_reason

  def should_push_to_salesforce?
    program.v2?
  end

  def to_ma_object
    make_ma_object(%i[crm_custom_fields status status_date dismissal_reason], %i[patient program])
  end

  def ma_object_message_group
    patient.ma_id
  end

  private

  def get_ma_sequence_identifier
    program_ma_id = self.program.ma_id&.split("_")&.last
    patient_ma_id = self.patient.ma_id&.split("_")&.last
    return nil unless program_ma_id && patient_ma_id
    
    "#{patient_ma_id}|#{program_ma_id}"
  end

  def patient_and_program_ma_id_must_exist
    return unless patient.persisted? && program.v2?

    if patient.ma_id.blank?
      errors.add(:patient, "is missing MA ID (go save it first)")
    end

    if program.ma_id.blank?
      errors.add(:program, "is missing MA ID (go save it first)")
    end
  end
end
