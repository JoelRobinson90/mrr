# frozen_string_literal: true

class PatientMrnDeduper < ApplicationService
  def initialize(pending_job_id)
    @pending_job_id = pending_job_id
  end

  def call
    patients_to_delete = Patient.where("first_name LIKE ? OR first_name LIKE ? OR first_name LIKE ?", "%DELETE%",
                                       "DUP %", "%DUP)%")
    patients_deleted_count = 0
    errors = []

    patients_to_delete.each do |patient|
      patient.address&.delete

      patient.appointments.each(&:delete)

      patient.delete
      patients_deleted_count += 1
    rescue StandardError => e
      errors.push(e)
    end

    dup_mrn_patients = Patient.select(:medical_record_number).group(:medical_record_number).having("count(*) > 1")
    patients_updated_count = 0

    dup_mrn_patients.each do |patient_basics|
      mrn = patient_basics.medical_record_number
      patient_to_upate = Patient.where(medical_record_number: mrn).first
      patient_to_upate.medical_record_number = "#{mrn}-1"
      patient_to_upate.external_id = "#{mrn}-1"
      patient_to_upate.save!
      patients_updated_count += 1
    rescue StandardError => e
      errors.push(e)
    end

    message = "#{patients_updated_count} patients updated, #{patients_deleted_count} patients deleted."

    pending_job = BackgroundJobResult.find_by(id: @pending_job_id)
    status = errors.length ? "error" : "success"

    if pending_job.present?
      pending_job.update(
        status:     status,
        message:    message,
        error_list: errors
      )
    end
  end
end
