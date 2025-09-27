# frozen_string_literal: true

module Mutations
  class CreatePatient < Mutations::BaseMutation
    argument :attributes,
             Types::Params::CreatePatientParams,
             required: true

    field :patient, Types::PatientType
    field :errors, [String], null: false

    def resolve(args)
      patient_args = args[:attributes].to_h
      demand_partner_id = patient_args[:demand_partner_id]
      demand_partner = DemandPartner.find(demand_partner_id)
      patient_args[:status] = PatientConstants::NEEDS_SCHEDULING_STATUS
      patient = demand_partner.patients.build(patient_args)
      patient.user.assign_random_password if patient.user && patient.user.password.blank?

      return {patient: nil, errors: [unauthorized_error]} unless can?(:create, patient)

      if patient.save
        {patient: patient, errors: []}
      else
        {patient: nil, errors: patient.errors.full_messages}
      end
    end
  end
end
