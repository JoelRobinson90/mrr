# typed: true
# frozen_string_literal: true

require "rails_helper"

# https://kipo.fandom.com/wiki/Timbercats
module Kipo
  class ImplementedBroker < Authentication::Broker
    class << self
      def auth_type
        :generic
      end
      %w[
        auth_type
        base_url
        headers
      ].each do |required_method|
        # Always required methods
        define_method(required_method) do
          "#{required_method}::defined"
        end
      end
    end
  end
end

module Kipo
  # No methods implemented
  class BensonDoesNotKnowSecurity < Authentication::Broker
    class << self
      def auth_type
        :basic
      end
    end
  end
end

RSpec.describe Authentication::Broker do
  describe "no methods implemented" do
    # auth_type
    %w[
      base_url
    ].each do |required_method|
      context "generic service" do
        it "does not implement #{required_method} by default" do
          expect do
            pp Kipo::BensonDoesNotKnowSecurity.send(required_method)
          end.to raise_error(NoMethodError,
                             "Required Kipo::BensonDoesNotKnowSecurity##{required_method} is not implemented")
        end
      end
    end

    %w[
      access_token_refresh_key
      refresh_body
      refresh_token_endpoint
      refresh_token_key
    ].each do |required_if_refresh_supported|
      context "refresh token provided by service" do
        module Kipo
          class Dave < Authentication::Broker
            class << self
              def refresh_token?
                true
              end
            end
          end
        end

        # Required methods if the endpoint issues refresh tokens

        it "##{required_if_refresh_supported} is not implemented by default but is required" do
          expect do
            Kipo::Dave.send(required_if_refresh_supported)
          end.to raise_error(NoMethodError, "Required Kipo::Dave##{required_if_refresh_supported} is not implemented")
        end
      end
    end
  end
end
