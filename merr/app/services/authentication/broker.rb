# typed: true
# frozen_string_literal: true

module Authentication
  # Abstract class acting as a base for Authentication of individual endpoints
  class Broker
    AUTH_TYPES = %i[
      barer_token
      basic
    ].freeze

    class << self
      %w[
        auth_type
        base_url
      ].each do |required_method|
        # Always required methods
        define_method(required_method) do
          raise NoMethodError, "Required #{name}##{__method__} is not implemented"
        end
      end

      def required_authentication_fufilled?
        case auth_type
        when :barer_token
          !auth_details.nil?
        when :basic
          defined?(auth_details)
        else
          raise NoMethodError,
                "Required #{name}##{__method__} is not implemented"
        end
      end

      def headers(_http_method)
        case auth_type
        when :basic
          unless defined?(auth_details)
            raise NoMethodError,
                  "Required #{name}#auth_details is not implemented for #{auth_type}"
          end
          {
            content_type:  "application/json",
            Authorization: "Basic #{Base64.strict_encode64(auth_details)}"
          }
        when :barer_token
          unless defined?(token)
            raise NoMethodError,
                  "Required #{name}#auth_details is not implemented for #{auth_type}"
          end
          {
            content_type:  "application/json; charset=utf-8",
            authorization: "Bearer #{token}"
          }
        else
          raise NoMethodError,
                "Required #{name}##{__method__} is not implemented for #{auth_type}"
        end
      end

      %w[
        access_token_expiration_key
        access_token_key
        auth_body
        auth_endpoint
        client_id
        client_secret
        refresh_token?
      ].each do |required_for_barer_token|
        # required methods if the endpoint is barer_token
        define_method(required_for_barer_token) do
          raise NoMethodError, "Required #{name}##{__method__} is not implemented" if auth_type == :barer_token
        end
      end

      %w[
        access_token_refresh_key
        refresh_body
        refresh_token_endpoint
        refresh_token_key
      ].each do |required_if_refresh_supported|
        # Required methods if the endpoint issues refresh tokens
        define_method(required_if_refresh_supported) do
          raise NoMethodError, "Required #{name}##{__method__} is not implemented" if refresh_token?
        end
      end
    end
  end
end
