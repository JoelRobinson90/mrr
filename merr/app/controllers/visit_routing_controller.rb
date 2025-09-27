# frozen_string_literal: true

# typed: true
class VisitRoutingController < ApplicationController
  before_action :authenticate_medarrive_user!, except: :get_options
  skip_before_action :verify_authenticity_token, only: :get_options

  def new_visit
    @route = Routing::VisitOptimizerWrapper.call(Patient.first, Time.zone.now, Time.zone.now + 1.week)
  end

  def get_options
    if params[:visit_optimizer_secret_key] != EnvHelper.env_or_nil("VISIT_OPTIMIZER_SECRET_KEY")
      render plain: "Unauthorized", status: :unauthorized and return
    end

    [:visits, :shifts, :parameters, :options].each do |expected_param|
      render plain: "Bad request", status: :bad_request and return if params[expected_param].nil?
    end

    visits = JSON.parse(params[:visits]).map(&->(i) { parse_timestamps(i) })
    shifts = JSON.parse(params[:shifts]).map(&->(i) { parse_timestamps(i) })
    parameters = JSON.parse(params[:parameters]).symbolize_keys
    options = JSON.parse(params[:options]).symbolize_keys
    options[:current_time] = Time.zone.parse(options[:current_time]) if options[:current_time].present?

    begin
      result = Routing::VisitOptimizer.call(shifts, visits, parameters, options)

      render json: result.payload[:options]
    rescue StandardError => e
      render json: {"error": e.message}, status: :internal_server_error
    end
  end

  private

  def parse_timestamps(item)
    item["start_time"] = Time.zone.parse(item["start_time"]) if item["start_time"].present?
    item["end_time"] = Time.zone.parse(item["end_time"]) if item["end_time"].present?
    item.symbolize_keys
  end

  def authenticate_medarrive_user!
    user_not_authorized! unless current_user&.is_medarrive_account?
  end
end
