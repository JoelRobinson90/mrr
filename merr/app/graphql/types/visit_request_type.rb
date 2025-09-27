# frozen_string_literal: true

module Types
  class VisitRequestType < Types::BaseObject
    field :id, ID, null: false
    field :program_id, Integer, null: false
    field :patient_id, Integer, null: false
    field :creator_id, Integer, null: false
    field :program, ProgramType, null: false
    field :patient, PatientType, null: false
    field :creator, UserType, null: false
    field :services, [ServiceType], null: false
    field :cancelled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :status, VisitRequestStatusType, null: false
  end
end
