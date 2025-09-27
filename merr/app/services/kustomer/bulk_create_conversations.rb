# typed: true
# frozen_string_literal: true

module Kustomer
  class BulkCreateConversations < ::ApplicationService
    attr_accessor :endpoint, :conversations_body

    def initialize(conversations_body)
      @api = Authentication::Api.new(Authentication::KustomerBroker)
      @endpoint = "conversations/bulk"
      @conversations_body = conversations_body
    end

    def call
      @api.post(endpoint, conversations_body)
    end
  end
end
