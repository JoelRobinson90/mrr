# frozen_string_literal: true

module Types
  class DemandCoordinatorType < Types::BaseObject
    implements Types::UserAccount

    field :demand_partner_id, Integer
    field :demand_partner, DemandPartnerType
  end
end
