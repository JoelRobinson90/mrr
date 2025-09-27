# frozen_string_literal: true

# typed: true
Sentry.init do |config|
  config.dsn = EnvHelper.env_or_nil("SENTRY_DSN")

  # Default is true
  config.rails.report_rescued_exceptions = true

  # this gem also provides a breadcrumb logger that accepts instrumentations from ActiveSupport
  config.breadcrumbs_logger = [:active_support_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:

  config.traces_sample_rate = case Rails.env
                              when "stage"
                                0.5 # 50% send rate for metrics
                              when "production"
                                0.1 # 10% send rate for metrics
                              end

  # HOST_ENV is set by terraform in all our hosted environments because Rails.env will be prod in all of them.
  config.environment = EnvHelper.env_or_nil("HOST_ENV") || "dev"

  config.enabled_environments = %w[test stage prod]

  # This isnt actually required. The background job processor for Sentry
  # is built into the gem. This is just for additional configuration.
  # Leaving for future reference as we are working for Setnry configurations
  # config.async = lambda do |event, hint|
  #   # TODO: set up delayed_job or sidekick
  #   Sentry::SendEventJob.perform_now(event, hint)
  # end
end
