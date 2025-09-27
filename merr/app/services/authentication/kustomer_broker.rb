# typed: true
# frozen_string_literal: true

module Authentication
  class KustomerBroker < Authentication::Broker
    class << self
      def auth_type
        :barer_token
      end

      def auth_details
        token
      end

      def auth_body
        {
          apiKey: client_id,
          secret: client_secret
        }
      end

      def token
        # Barer token is actually called KUSTOMER_API_KEY
        EnvHelper.env_or_error("KUSTOMER_API_KEY")
      end

      def base_url
        "https://api.kustomerapp.com/v1"
      end
    end
  end
end
