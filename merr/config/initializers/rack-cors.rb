# frozen_string_literal: true

# typed: true
## Configure Rack CORS Middleware, so that CloudFront can serve our assets.
## See https://github.com/cyu/rack-cors

if defined? Rack::Cors
  Rails.configuration.middleware.insert_before 0, Rack::Cors do
    allow do
      origins %w[
        https://stage-app.medarrive.com
        https://stage-web.medarrive.com
        https://prod-web.medarrive.com
        https://app.medarrive.com
        https://test-web.medarrive.com
        https://test-app.medarrive.com
      ]
      resource "/assets/*"
      resource "/packs/*"
    end
  end
end
