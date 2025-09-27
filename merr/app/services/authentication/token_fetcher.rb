# typed: true
# frozen_string_literal: true

module Authentication
  class TokenFetcher < ApplicationService
    require "rest-client"

    TOKEN_EXPIRATION_BUFFER = 30.seconds

    cattr_reader :cached_tokens
    attr_reader :broker

    def initialize(broker)
      @broker = broker
      @@cached_tokens ||= {}
    end

    def call
      return unless @broker.client_id && @broker.client_secret

      get_cached_token || fetch_and_cache_new_token
    end

    def self.reset_cache
      @@cached_tokens = {}
    end

    private

    def get_cached_token
      token, refresh, exp = @@cached_tokens[@broker.client_id]
      token if exp&.future?
    end

    def refresh_token
      # TODO: Palceholder for refrsh logic
      fetch_auth_token_result # This is not the final logic
      # TODO: Add refresh handling
    end

    def fetch_and_cache_new_token
      result = @broker.refresh_token? ? refresh_token : fetch_auth_token_result

      if result.success?
        refresh = @broker.refresh_token? ? result.payload[@broker.access_token_refresh_key] : nil
        exp_input = result.payload[@broker.access_token_expiration_key]
        exp_offset = Integer(exp_input) rescue false
        exp = if exp_offset
          # exp_input is number of seconds from now
          Time.zone.now + (exp_offset - TOKEN_EXPIRATION_BUFFER)
        else
          # exp_input is date
          Time.zone.parse(exp_input) - TOKEN_EXPIRATION_BUFFER
        end
        @@cached_tokens[@broker.client_id] = [result, refresh, exp]
        result
      else
        # TODO: How to fail gracefully?
        # Backoff and retry?
        OpenStruct.new({success?: false, error: "Could not fetch token"})
      end
    end

    def fetch_refresh_token_result
      # TODO: Implement
    end

    def fetch_auth_token_result
      headers = {
        content_type: "application/x-www-form-urlencoded"
      }

      begin
        headers.merge!(@broker.auth_headers) if @broker.respond_to?(:auth_headers)

        response = RestClient.post(@broker.auth_endpoint, @broker.auth_body, headers: headers)
        OpenStruct.new({success?: true, payload: JSON.parse(response.body)})
      rescue RestClient::Exception => e
        OpenStruct.new({success?: false, error: "Could not fetch token #{e}"})
      end
    end
  end
end
