# frozen_string_literal: true

module Queries
  module PatientQueries
    def get_patient(id: nil, ma_id: nil)
      return nil if id.blank? && ma_id.blank?

      patient = Patient.find_by_maybe_ma_id(id: id, ma_id: ma_id)
      return nil unless patient && authorized?(:read, patient)

      patient
    end

    def get_patients(ids:, page:, per_page:, lookahead:, search: "", program_id: "")
      patients = Patient.accessible_by(current_ability).paginate(page: page, per_page: per_page)
      patients = patients.includes(:address) if lookahead.selects?(:address)
      patients = patients.where(id: ids) if ids
      patients = patients.search(search) if search.present?

      if program_id.present?
        patients = patients.joins(:patient_programs).where(patient_programs: {program_id: program_id})
      end

      patients
    end
  end
end
