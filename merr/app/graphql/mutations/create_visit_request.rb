# frozen_string_literal: true

module Mutations
  class CreateVisitRequest < Mutations::BaseMutation
    argument :attributes,
             Types::Params::CreateVisitRequestParams,
             required: true

    field :visit_request, Types::VisitRequestType, null: true
    field :errors, [String], null: false

    def resolve(attributes:)
      patient = Patient.new({**attributes[:patient], status: PatientConstants::NEEDS_SCHEDULING_STATUS})
      patient.user = nil if attributes.dig(:patient, :user_attributes, :email).blank?
      patient.user.assign_random_password if patient.user && patient.user.password.blank?

      visit_request = VisitRequest.new(
        # TODO: pass program_id and service_ids when they are passed in from the form
        # program_id: attributes[:program_id],
        # service_ids: attributes[:service_ids],
        program_id: patient.demand_partner.programs.first&.id,
        patient:    patient,
        creator:    current_user
      )

      return {visit_request: nil, errors: [unauthorized_error]} unless can?(:create,
                                                                            patient) && can?(:create, visit_request)

      if visit_request.save
        {visit_request: visit_request, errors: []}
      else
        {visit_request: nil, errors: visit_request.errors.full_messages}
      end
    end
  end
end
