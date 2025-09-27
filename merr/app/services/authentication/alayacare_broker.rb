# typed: true
# frozen_string_literal: true

module Authentication
  class AlayacareBroker < Authentication::Broker
    class << self
      def auth_type
        :basic
      end

      def auth_details
        "#{EnvHelper.env_or_error('ALAYACARE_PUBLIC_KEY')}:#{EnvHelper.env_or_error('ALAYACARE_PRIVATE_KEY')}"
      end

      def base_url
        # For production envs,
        # there is no ALAYACARE_ENVIRONMENT so this needs to strip
        # out the empty and join into a valid url
        ["https://medarrive",
         EnvHelper.env_or_nil("ALAYACARE_ENVIRONMENT"),
         "alayacare.com/ext/api/v2"].compact.join(".")
      end

      def headers(http_method)
        custom_headers = {Authorization: "Basic #{Base64.strict_encode64(auth_details)}"}

        custom_headers[:content_type] = "application/json" unless http_method == :get

        custom_headers
      end
    end
  end
end
