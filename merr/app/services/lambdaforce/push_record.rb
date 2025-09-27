# frozen_string_literal: true

module Lambdaforce
  class PushRecord < ApplicationService
    attr_reader :payload, :synchronous

    def initialize(payload, synchronous = false)
      @payload = payload
      @synchronous = synchronous || !!EnvHelper.env_or_nil("LAMBDAFORCE_ALWAYS_SYNC")
    end

    def call
      return OpenStruct.new(success?: false) unless perform_sync?

      begin
        response = RestClient.post(url, payload.to_json, {
                                     "Content-Type": "application/json",
                                     "X-Api-Key":    api_key
                                   })

        OpenStruct.new(success?: true, payload: response.body)
      rescue RestClient::Exception => e
        # TODO: log failure
        OpenStruct.new(success?: false, payload: e.response.body)
      end
    end

    private

    def perform_sync?
      !!EnvHelper.env_or_nil("ENABLE_PUSH_TO_EXTERNAL")
    end

    def url
      host = EnvHelper.env_or_nil("LAMBDAFORCE_HOST")
      path = synchronous ? "/sfdcInboundSync" : "/sfdcInbound"
      host + path
    end

    def api_key
      EnvHelper.env_or_nil("LAMBDAFORCE_OUTBOUND_SECRET")
    end
  end
end
