module Types
  class ServiceRequestType < Types::BaseObject
    field :id, ID, null: false
    field :ma_id, ID, null: false
    field :patient_id, ID, null: false
    field :program_id, ID, null: false
    field :service_id, ID, null: false
    field :status, String, null: false
    field :status_detail, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :refusal_reason, String, null: true
  end
end
