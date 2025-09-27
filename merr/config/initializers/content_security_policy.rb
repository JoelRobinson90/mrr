# frozen_string_literal: true

# typed: strict
# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

asset_host = EnvHelper.env_or_nil("ASSET_HOST") || ""
host = EnvHelper.env_or_nil("HOST") || ""

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https

  policy.font_src        :self,
                         asset_host,
                         host,
                         "*.medarrive.com",
                         "https://fonts.gstatic.com"

  policy.img_src         :self, :https, :data, asset_host, host

  policy.object_src      :none

  policy.script_src      :self,
                         asset_host,
                         host,
                         "*.medarrive.com",
                         "https://api.mapbox.com"

  policy.style_src       :self,
                         :unsafe_inline,
                         asset_host,
                         host,
                         "*.medarrive.com",
                         "https://fonts.googleapis.com",
                         "https://api.mapbox.com"

  policy.frame_ancestors :self,
                         "*.force.com"

  # If you are using webpack-dev-server then specify webpack-dev-server host
  policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"

  # Add unsafe eval to graphiql controller only
  if Rails.env.development?
    # While the gem is loaded up front, its controller is autoloaded.
    # Therefore we must ensure our patch runs after loading, every time.
    Rails.autoloaders.main.on_load("GraphiQL::Rails::EditorsController") do
      GraphiQL::Rails::EditorsController.content_security_policy do |policy|
        policy.script_src(*policy.script_src, :unsafe_eval)
      end
    end
  end
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

# Only apply nonce to scripts; not compatible with unsafe-inline for styles
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only

# TODO: turn on report mode in dev only once confirmed working in prod
Rails.application.config.content_security_policy_report_only = false
