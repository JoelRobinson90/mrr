# frozen_string_literal: true

module Types
  class PatientType < Types::BaseObject
    field :id, ID, null: false
    field :external_id, String, null: true
    field :ma_id, ID, null: true
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :date_of_birth, GraphQL::Types::ISO8601Date, null: true
    # field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    # field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    # field :middle_initial, String, null: true
    field :phone_number, String, null: true
    # field :secondary_phone_number, String, null: true
    field :medical_record_number, String, null: true
    # field :emergency_contact_name, String, null: true
    # field :emergency_contact_phone_number, String, null: true
    # field :demand_partner_id, Integer, null: false
    field :demand_partner, Types::DemandPartnerType, null: true
    # field :patient_notes, String, null: true
    # field :primary_care_physician_id, Integer, null: true
    field :sex, String, null: true
    field :contact_email, String, null: true
    # field :gender, String, null: true
    # field :preferred_pronouns, String, null: true
    # field :status, String, null: false
    field :consent_to_text, Boolean, null: true
    # field :needs_hra_survey, Boolean, null: true
    field :preferred_language, String, null: true
    # field :race, String, null: true
    # field :ethnicity, String, null: true
    # field :phone_number_type, String, null: true
    # field :secondary_phone_number_type, String, null: true
    # field :region, String, null: true
    # field :primary_risk_category, String, null: true
    field :address, Types::AddressType, null: true
    field :display_name, String, null: false
    field :programs, [Types::ProgramType], null: true

    field :service_requests, [Types::ServiceRequestType], null: false do
      argument :status, String, required: false
    end

    def service_requests(status: nil)
      req = object.service_requests
      req = req.where(status: status) if status
      req
    end
  end
end
