# frozen_string_literal: true

# typed: true
require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MedArrive
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.session_store(
      :cookie_store,
      key: '_medarrive_session',
      secure: Rails.env.production?
    )
    # config.action_mailer.perform_caching = false
    # config.action_mailer.raise_delivery_errors = true
    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = {
    #   address: 'email-smtp.us-east-1.amazonaws.com',
    #   port: 587,
    #   user_name: ENV['SES_SMTP_USERNAME'],
    #   password: ENV['SES_SMTP_PASSWORD'],
    #   authentication: :login,
    #   enable_starttls_auto: true
    # }

    # this determines whether you can add extra files to e.g. provider certifications.
    config.active_storage.replace_on_assign_to_many = false
    config.assets.initialize_on_precompile = false

    # We will need to enable this if we seperate the GraphQL server and client onto different hosts.
    # Rails.application.config.middleware.insert_before 0, Rack::Cors do
    #   allow do
    #     origins 'localhost:3000'

    #     resource '*',
    #       headers: :any,
    #       expose: ['access-token', 'expiry', 'token-type', 'Authorization'],
    #       credentials: true,
    #       methods: [:get, :post, :put, :patch, :delete, :options, :head]
    #   end
    # end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
