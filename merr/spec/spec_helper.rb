# typed: true
# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "simplecov"

require_relative "./support/vcr_setup"

SimpleCov.start "rails"

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.around(:each, :run_delayed_jobs) do |example|
    Delayed::Worker.delay_jobs = false

    example.run

    Delayed::Worker.delay_jobs = true
  end

  # Timecop for known date time
  config.around(:each) do |example|
    # Set known date
    Timecop.freeze(Time.zone.local(2020, 3, 21))

    name = example.full_description.gsub(/[^\w\-]/, "_")
    VCR.use_cassette(name, record: :new_episodes) do
      # Run test
      example.run
    end

    # Back to the future
    Timecop.return
  end
end
