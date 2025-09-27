# typed: true
# frozen_string_literal: true

Rails.application.configure do
  if Rails.env.development?
    config.action_mailer.default_url_options = {host: "localhost", port: 3000}
    config.action_mailer.perform_deliveries = false

    # Use Postmark for mailing
    config.action_mailer.delivery_method = :postmark

    config.action_mailer.postmark_settings = {
      api_token: EnvHelper.env_or_error("POSTMARK_API_KEY")
    }
  end
end
