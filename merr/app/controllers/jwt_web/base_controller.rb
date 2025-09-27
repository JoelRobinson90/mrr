# frozen_string_literal: true

module JwtWeb
  class BaseController < ::ApplicationController
    include JwtAuth

    layout "jwt_web"

    # These are one-off pages that are available outside of our site
    # i.e. in a Salesforce iframe
    # Pages are rendered whether or not a valid token is passed
    # The front end accepts a token passed via JS message and uses it in API calls
  end
end
