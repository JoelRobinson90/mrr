# typed: true
# frozen_string_literal: true

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

ENV["ENABLE_PUSH_TO_EXTERNAL"] = "false"

ENV["ALAYACARE_PRIVATE_KEY"] = "TEST"
ENV["ALAYACARE_PUBLIC_KEY"] = "TEST"
ENV["GOOGLE_SERVICES_API_KEY"] = "TEST"
ENV["GOOGLE_SERVICES_PROJECT_ID"] = "TEST"
ENV["POSTMARK_API_KEY"] = "TEST"
ENV["POSTMARK_SERVER_ID"] = "TEST"
ENV["SMS_OUTBOUND_NUMBER"] = "TEST"
ENV["TWILIO_ACCOUNT_SID"] = "TEST"
ENV["TWILIO_API_KEY"] = "TEST"
ENV["ALAYACARE_ENVIRONMENT"] = "uat"
ENV["ALAYACARE_PRIVATE_KEY"] = "Me7Igfjat7AONlJnIbw74R7HmcEgDqQ1cRZBVcfDj3Y"
ENV["ALAYACARE_PUBLIC_KEY"] = "qUuB6QckWCcDluHgDOmMP47FFew"
ENV["SENTRY_DSN"] = "TEST"
ENV["HOST"] = "http://localhost:3000"
ENV["KUSTOMER_API_KEY"] =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYxZjk2YzQ1OWExNWIyMGI1N2U2MTUwNCIsInVzZXIiOiI2MWY5NmM0NGJjNzBmZDU4MDhlMGYxZmMiLCJvcmciOiI2MTFiZTlkNDUxZWM2YjYzYTEwMTFkM2MiLCJvcmdOYW1lIjoibWVkYXJyaXZlLXNhbmRib3giLCJ1c2VyVHlwZSI6Im1hY2hpbmUiLCJwb2QiOiJwcm9kMSIsInJvbGVzIjpbIm9yZyJdLCJhdWQiOiJ1cm46Y29uc3VtZXIiLCJpc3MiOiJ1cm46YXBpIiwic3ViIjoiNjFmOTZjNDRiYzcwZmQ1ODA4ZTBmMWZjIn0.TZeMA4eMOXwzECfvgGQxAZmZjlhKAe7-cZvtwxhsrEI"
ENV["MAPBOX_API_TOKEN"] = "pk.eyJ1IjoiYmVyZ3NvcmUiLCJhIjoiY2tsZ3h4cThtMTVhcjJ2bXVwdDhyc2JhNyJ9.EEiwRf9O-r0FPGr5Jes2BA"
ENV["SLACK_CRON_NOTIFICATIONS_WEBHOOK"] = "TEST"
ENV["WHENIWORK_TOKEN"] =
  "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHAiOiIxIiwiaWF0IjoxNjQxODQwMjM0LCJsb2dpbiI6IjE5Mjc0MjY2IiwicGlkIjoiMTkyNzQyNjYifQ.BdPcCZcyKqCrRPePmJEs-HggGGWo3alkWz5X3WLm3mj15rSS_EApVu8raRNDrUlgieYHrWXqHmhqeDC04wPMlq5eIP1Yv3muLZHcbm7zMw0kH_zcT1HtxNlV51ZHJ8aFXKBy6IXK4H_WAF5KkN04fyX6hM8zJouKoLixCDgMS2xWKl0oe8Ax_oCeMeQpppEEae1I5rkzSQpN_w--5p4MUzXLVHzU6mM5QW3wGCbSWdag-18wQ1OZxKOrX5TlpqvW_HrMFmYOJFnPlhsH846G6Kw1aJATdy8RdNuKJVQGa1BZ26ZUTvKwoLbZ7PTyISwWzAD_lwjCRVb6uY_7kl17YA"
ENV["OKTA_URL"] = "https://medarrive.okta.com"
ENV["VALHALLA_URL_BASE"] = "http://3.237.224.45:8002"
ENV["MA_ID_PREFIX"] = "spec"
ENV["ATHENA_PRACTICE_ID"] = "27646"
ENV["ATHENA_BASE_URL"] = "https://api.preview.platform.athenahealth.com"
ENV["ATHENA_CLIENT_ID"] = "0oag8cvsnzNt58Vwl297"
ENV["ATHENA_CLIENT_SECRET"] = "3Q4CJrXaY_hgz-nNscFFVm02SpKOrcJS75tesqkl"
ENV["LAMBDAFORCE_OUTBOUND_SECRET"] = "lambdaforce-outgoing-secret-value"
ENV["LAMBDAFORCE_INBOUND_SECRET"] = "lambdaforce-inbound-secret-value"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = false
  config.action_view.cache_template_loading = true

  config.active_job.queue_adapter = :test

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.action_mailer.default_url_options = {host: ENV["HOST"]}

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true
end
