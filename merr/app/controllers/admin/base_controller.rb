# typed: true
# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_medarrive_account!
    before_action :get_pagination_params, only: %i[index route_index]
    before_action :reset_breadcrumbs, only: :index

    layout "admin"

    private

    def authenticate_medarrive_account!
      user_not_authorized! unless current_user&.is_medarrive_account?
    end

    def layout_props
      super.merge(
        breadcrumbs: stored_breadcrumbs
      )
    end

    def reset_breadcrumbs(text = nil)
      session[:breadcrumbs] = [{
        text: text || controller_name.humanize,
        href: request.path
      }]
    end

    def get_pagination_params
      @current_page = params[:page].present? ? params[:page].to_i : 1
      @per_page = params[:rows_per_page].present? ? params[:rows_per_page].to_i : 100
    end

    def appointment_stats(appointments)
      awaiting_scheduled_ids = appointments.where(status: "Awaiting Scheduling").pluck(:id).uniq
      total = awaiting_scheduled_ids.count
      plus_ones = ExtraVaccineRecipient.where(appointment_id: awaiting_scheduled_ids, confirmed: true).count
      vaccines = total + plus_ones
      {
        total:     total,
        plus_ones: plus_ones,
        vaccines:  vaccines
      }
    end
  end
end
