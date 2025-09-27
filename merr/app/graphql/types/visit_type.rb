# frozen_string_literal: true

# Currently served by Alayacare::FetchVisit hash
module Types
  class VisitType < Types::BaseObject
    field :id, ID, null: false
    field :external_id, ID, null: false
    field :ma_id, ID, null: false
    field :patient, Types::PatientType, null: true
    field :patient_id, ID, null: true
    field :field_provider_id, Integer, null: true
    field :arrival_window_start, String, null: true
    field :arrival_window_end, String, null: true
    field :field_provider, Types::FieldProviderType, null: true
    field :program_id, ID, null: false
    field :program, Types::ProgramType, null: true
    field :start_time, GraphQL::Types::ISO8601DateTime, null: false
    field :end_time, GraphQL::Types::ISO8601DateTime, null: false
    field :service_instructions, String, null: true
    field :canceled, Boolean, null: true
    field :cancel_code_id, ID, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :visit_type_id, ID, null: false
    field :visit_type, Types::VisitTypeType, null: false
    field :visit_request_id, ID, null: true
    field :admin_notes, [Types::AdminNoteType], null: true
    field :notes, [Types::AlayacareVisitNoteType], null: true
    field :cx_end, String, null: true
    field :cx_start, String, null: true
    field :destination, String, null: true
    field :destination_drive_time, Integer, null: true
    field :service_ids, [ID], null: false
    field :services, [Types::ServiceType], null: true
    field :visit_events, [Types::VisitEventType], null: true
    field :alayacare_status, String, null: true
    field :display_status, String, null: true
    field :athena_telehealth_url, String, null: true
    field :visit_group, Types::VisitGroupType, null: true
    field :providers, [Types::FieldProviderType], null: true
    field :confirmed, Boolean, null: true

    def admin_notes
      object.admin_notes.order(created_at: :desc)
    end
  end
end
