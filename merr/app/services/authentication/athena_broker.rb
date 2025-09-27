# typed: true
# frozen_string_literal: true

module Authentication
  class AthenaBroker < Authentication::Broker
    class << self
      def headers(http_method)
        custom_headers = {
          # Required for sending POST/PUT body
          content_type: "application/x-www-form-urlencoded",
          # Prevent gzip error when getting a 400 back
          accept_encoding: "identity"
        }
        super(http_method).merge(custom_headers)
      end

      def auth_type
        :barer_token
      end

      def required_authentication_fufilled?
        !token.nil?
      end

      def token
        token_fetch = Authentication::TokenFetcher.call(self)
        Rails.logger.error("Authentication failed. Verify endpoint and secrets") and return unless token_fetch.success?

        token_fetch.payload[access_token_key]
      end

      def base_url
        base = EnvHelper.env_or_nil("ATHENA_BASE_URL")
        practice_id = EnvHelper.env_or_nil("ATHENA_PRACTICE_ID")
        "#{base}/v1/#{practice_id}" 
      end

      def auth_endpoint
        "#{EnvHelper.env_or_nil("ATHENA_BASE_URL")}/oauth2/v1/token"
      end

      def auth_body
        {
          grant_type: "client_credentials",
          scope: "athena/service/Athenanet.MDP.*",
          client_id: client_id,
          client_secret: client_secret
        }
      end

      def access_token_key
        "access_token"
      end

      def access_token_expiration_key
        "expires_in"
      end

      def client_id
        EnvHelper.env_or_nil("ATHENA_CLIENT_ID")
      end

      def client_secret
        EnvHelper.env_or_nil("ATHENA_CLIENT_SECRET")
      end

      def refresh_token?
        false
      end
    end
  end
end
