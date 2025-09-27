# frozen_string_literal: true

# NOTE: JWT logic extracted from this tutorial https://developer.okta.com/blog/2021/07/20/rails-guide-securing-api

module JwtAuth
  extend ActiveSupport::Concern

  included do
    attr_reader :jwt_current_user

    def valid_jwt?
      return @valid_jwt unless @valid_jwt.nil?

      # if id_token, validate both locally
      # if just token, do remote validation
      @valid_jwt = if !request_access_token
                     false
                   elsif !request_id_token
                     remote_validate_token(request_access_token).present?
                   else
                     local_validate_token(request_access_token, request_id_token).present?
                   end
    end

    def current_user
      # Called first to initially load current user
      valid_jwt?
      @jwt_current_user || super
    end

    def request_access_token
      request.headers["HTTP_AUTHORIZATION"]&.gsub("Bearer ", "")
    end

    def request_id_token
      request.headers["IDTOKEN"]
    end

    private

    def local_validate_token(token, id_token)
      return false unless token

      begin
        keys = Rails.cache.fetch("okta_private_keys", expires_in: 30.minutes) do
          response_request = RestClient.get("#{ENV['OKTA_URL']}/oauth2/default/v1/keys")

          if response_request.code == 200
            # need to parse the body
            json_response = JSON.parse(response_request.body)
            json_response["keys"]
          end
        end

        token_payload = JWT.decode(token, nil, true, {algorithms: ["RS256"], jwks: {keys: keys}})

        id_token_payload = JWT.decode(id_token, nil, true, {algorithms: ["RS256"], jwks: {keys: keys}})

        payload_data    = id_token_payload[0]
        name            = payload_data&.dig("name")
        email           = payload_data&.dig("email")
        ma_account_type = payload_data&.dig("ma_account_type")
        ma_field_org    = payload_data&.dig("ma_field_org")

        # @TODO: check for FP role, also possibly trigger error if no FP ?
        @jwt_current_user = User.find_by email: email
      rescue StandardError
        return false
      end

      @jwt_current_user.present?
    end

    def remote_validate_token(token)
      userinfo_result = Okta::GetUserInfo.call(token)
      return false unless userinfo_result.success?

      userinfo = userinfo_result.payload
      @jwt_current_user = User.from_auth_user(
        AuthUser.from_userinfo(userinfo)
      )

      @jwt_current_user.present?
    end
  end
end
