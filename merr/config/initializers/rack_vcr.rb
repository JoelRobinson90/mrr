# typed: true
# frozen_string_literal: true

# Only record server calls in test
Rails.configuration.middleware.insert(0, Rack::VCR) if Rails.env.test?
