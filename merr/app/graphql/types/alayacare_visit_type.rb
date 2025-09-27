# frozen_string_literal: true

module Types
  class AlayacareVisitType < Types::BaseObject
    field :alayacare_visit_id, String
    field :fp_id, String
    field :location, String
    field :start_time, String
    field :end_time, String
    field :demand_partner_id, ID
    field :patient, PatientType
    field :status, String
    field :client_id, ID
  end
end
