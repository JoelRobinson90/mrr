# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.ignore_hosts "www.example.com", "chrome", ENV["SERVER_NAME"], "webpack"

  # TODO: Configure sensitive data based on future requests
  protected_keys = %w[
    ETag
    Set-Cookie
    X-Runtime
    ALAYACARE_ENVIRONMENT
    ALAYACARE_PRIVATE_KEY
    ALAYACARE_PUBLIC_KEY
    GOOGLE_MAPS_API_KEY
    GOOGLE_SERVICES_API_KEY
    GOOGLE_SERVICES_PROJECT_ID
    POSTMARK_API_KEY
    POSTMARK_SERVER_ID
    SMS_OUTBOUND_NUMBER
    TWILIO_ACCOUNT_SID
    TWILIO_API_KEY
    KUSTOMER_API_KEY
    WHENIWORK_TOKEN
  ]

  protected_keys.each do |key|
    config.filter_sensitive_data("<#{key}>") { ENV[key] }
  end

  protected_keys.each do |key|
    # TODO: Make this remove the Basic Auth Headers
    config.filter_sensitive_data("<BASIC #{key}>") do
      replacement = ENV[key] || "Basic Replacement"
      "Basic #{Base64.strict_encode64(replacement)}"
    end
  end

  protected_keys.each do |key|
    # TODO: Make this remove the BEARER Auth Headers
    config.filter_sensitive_data("<BEARER #{key}>") do
      "Bearer #{key}"
    end
  end

  match_requests_on = %i[method uri body]
end
