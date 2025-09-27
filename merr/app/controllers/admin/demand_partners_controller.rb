# frozen_string_literal: true

# typed: true
module Admin
  class DemandPartnersController < BaseController
    load_and_authorize_resource

    def index
      render_component "DemandPartnerIndexPage", demand_partners: @demand_partners
    end

    def show
      append_breadcrumb(@demand_partner.name)
      @templates = SmsTemplate.where(demand_partner: @demand_partner)

      demand_partner_json = Jbuilder.encode do |json|
        json.id @demand_partner.id
        json.name @demand_partner.name

        json.templates(@templates) do |template|
          json.id template.id
          json.message_type template.message_type
          json.message_body template.message_body
          json.created_at template.created_at
        end
      end

      render_component "DemandPartnerShowPage", demand_partner: JSON.parse(demand_partner_json)
    end
  end
end
