# typed: true
# frozen_string_literal: true

module Authentication
  class WhenIWorkBroker < Authentication::Broker
    class << self
      def auth_type
        :barer_token
      end

      def auth_details
        token
      end

      def token
        EnvHelper.env_or_error("WHENIWORK_TOKEN")
      end

      def base_url
        "https://api.wheniwork.com/2"
      end

      def refresh_token?
        false
      end

      # NOTE:
      #  WhenIWork has a 2-step process where you can request a token for a particular user
      #  However, I wasn't able to get it working because calling TokenFetcher in 'token'
      #  seems to loop by requiring 'auth_details'. 
      #  For now I'm just generating a broker token and using that directly.  I don't think
      #  it expires.  But I'll leave this code commented in case we need to fix it later.

      # def auth_endpoint
      #   "https://api.login.wheniwork.com/login"
      # end

      # def auth_body
      #   {
      #     username: EnvHelper.env_or_error("WHENIWORK_USERNAME"),
      #     password: EnvHelper.env_or_error("WHENIWORK_PASSWORD")
      #   }
      # end

      # def auth_headers
      #   {
      #     "W-Key" => client_id,
      #     content_type: "application/json; charset=utf-8"
      #   }
      # end

      # def access_token_key
      #   "token"
      # end

      # def client_id
      #   EnvHelper.env_or_error("WHENIWORK_USERNAME_API_KEY")
      # end

      # # not actually needed but Broker class needed to be defined.
      # def client_secret
      #   EnvHelper.env_or_error("WHENIWORK_USERNAME_API_KEY")
      # end
    end
  end
end
