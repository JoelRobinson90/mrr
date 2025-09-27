# frozen_string_literal: true

class GraphqlController < ApplicationController
  include JwtAuth

  # All Graphql endpoints access the same schema
  # - /graphql is for Rails session auth
  # - /graphql_jwt is for external JWT auth
  # - /graphql_dev has no auth and is only exposed in development

  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  protect_from_forgery with: :null_session

  before_action :authenticate_user!, only: [:execute]
  before_action :authenticate_jwt!, only: [:execute_jwt]
  before_action :ensure_dev_env!, only: [:execute_dev]

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user:    current_user,
      current_ability: current_user && Ability.new(current_user)
    }
    result = MedArriveSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    handle_graphql_error(e)
  end
  alias execute_jwt execute
  alias execute_dev execute

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def authenticate_user!
    render_graphql_error("Error: user not authenticated", status: :unauthorized) unless current_user
  end

  def authenticate_jwt!
    render_graphql_error("Error: user not authenticated", status: :unauthorized) unless valid_jwt?
  end

  def ensure_dev_env!
    render_graphql_error("Error: not allowed") unless Rails.env.development?
  end

  # GraphQL errors are mainly used for unauthenticated users and server side errors
  # Not found and authorization fails should return 200 and nil
  # Mutation validation errors should return 200 with an errors array

  def handle_graphql_error(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")
    Sentry.capture_exception(e)

    render_graphql_error(e.message, backtrace: e.backtrace)
  end

  def render_graphql_error(message, data: {}, backtrace: nil, status: 500)
    backtrace = nil if Rails.env.production?
    render json: {errors: [{message: message}], data: data, backtrace: backtrace}, status: status
  end
end
