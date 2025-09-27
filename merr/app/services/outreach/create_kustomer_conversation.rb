# frozen_string_literal: true

module Outreach
  class CreateKustomerConversation < ApplicationService
    attr_reader :customer_id, :tags, :custom_fields, :name

    def initialize(customer_id:, tags:, custom_fields:, name: nil)
      @customer_id = customer_id
      @tags = tags
      @custom_fields = custom_fields
      @name = name

      @kustomer_api = Authentication::Api.new(Authentication::KustomerBroker)
    end

    def call
      body = {
        customer: customer_id,
        name:     "[Auto Outreach] #{name}",
        custom:   custom_fields
      }
      conversation_response = Kustomer::Helper.parse_response(@kustomer_api.post("conversations", body))
      unless conversation_response.success?
        return OpenStruct.new({success?: false,
                               error:    conversation_response.errors})
      end

      conversation_body = JSON.parse(conversation_response.body)
      conversation_id = conversation_body["data"]["id"]

      if tags.present?
        tags_response = Kustomer::Helper.parse_response(@kustomer_api.post("conversations/#{conversation_id}/tags", tags))

        return OpenStruct.new({success?: false, error: tags_response.errors}) unless tags_response.success?
      end

      OpenStruct.new({success?: true, payload: {
                       conversation_id: conversation_id
                     }})
    end
  end
end
