# typed: true
# frozen_string_literal: true
require "rest-client"

class ApiController < ActionController::Base
  include JwtAuth

  before_action :require_jwt

  private
  
  def require_jwt
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized unless valid_jwt?
  end
end
