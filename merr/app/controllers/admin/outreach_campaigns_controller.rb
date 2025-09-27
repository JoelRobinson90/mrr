# frozen_string_literal: true

module Admin
  class OutreachCampaignsController < BaseController
    def index
      render_component "OutreachCampaignsIndexPage", selected_campaign_id: params[:selected_campaign_id]
    end

    def send_one
      @outreach_campaign = OutreachCampaign.where(active: true).find(params[:id])
      @kustomer_customer_id = params[:kustomer_customer_id]
      @manual_mode = ActiveModel::Type::Boolean.new.cast(params[:manual_mode])

      result = Outreach::ContactPatient.call(@outreach_campaign, @kustomer_customer_id, manual_mode: @manual_mode)

      if result.success?
        flash[:notice] = "Success! Conversation ID: #{result.payload[:conversation_id]}"
      else
        flash[:alert] = "Error: #{result.error}"
      end

      redirect_to admin_outreach_campaigns_path, selected_campaign_id: params[:id]
    end
  end
end
