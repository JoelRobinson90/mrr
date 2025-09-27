# frozen_string_literal: true

module Types
  class ProgramType < Types::BaseObject
    field :id, ID, null: false
    field :ma_id, String, null: true
    field :name, String, null: false
    field :alayacare_service_code_id, String, null: false
    field :demand_partner_id, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :services, [Types::ServiceType], null: true
    field :visit_types, [Types::VisitTypeType], null: true
    field :demand_partner, Types::DemandPartnerType, null: true
    field :v2, Boolean, null: true
    field :active, Boolean
  end
end
