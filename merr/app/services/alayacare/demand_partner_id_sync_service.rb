module Alayacare
  class DemandPartnerIdSyncService < ::ApplicationService
    def initialize()
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
    end

    def call
      unmatched_groups = []
      matched_groups = []

      result = @api.get("patients/groups")
      groups = JSON.parse(result.body)["items"]

      groups.each do |ac_client_group|
        demand_partner_match = DemandPartner.find_by(name: ac_client_group["name"])
        if demand_partner_match.present?
          demand_partner_match.alayacare_id = ac_client_group["id"]
          demand_partner_match.save!
          matched_groups.push(demand_partner_match["name"])
        else
          unmatched_groups.push(ac_client_group["name"])
        end
      end

      { matched_groups: matched_groups, unmatched_groups: unmatched_groups }
    end
  end
end
