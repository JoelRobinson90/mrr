# frozen_string_literal: true

# typed: true
module Field
  class BaseController < ApplicationController
    before_action :authenticate_field_scheduler_user!
    before_action :get_pagination_params, only: %i[index route_index]

    layout "field"

    private

    def authenticate_field_scheduler_user!
      user_not_authorized! unless current_user&.is_field_scheduler?
    end

    def get_pagination_params
      @current_page = params[:page].present? ? params[:page].to_i : 1
      @per_page = params[:rows_per_page].present? ? params[:rows_per_page].to_i : 100
    end
  end
end
