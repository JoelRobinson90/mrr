# frozen_string_literal: true

# typed: true
unless Rails.env.development? || Rails.env.test?
  Datadog.configure do |c|
    # This will activate auto-instrumentation for Rails
    c.use :rails
    c.use :rest_client
  end
end
