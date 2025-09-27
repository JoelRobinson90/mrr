# frozen_string_literal: true

# typed: true
require "twilio-ruby"

module Sms
  class SmsProvider < ApplicationService
    def initialize(message)
      @from = message[:from]
      @to = Utility.sanitize_phone(message[:to])
      @body = message[:body]
    end

    def call
      validation_response = validate_message
      return validation_response unless validation_response[:success?]

      account_sid = EnvHelper.env_or_error("TWILIO_ACCOUNT_SID")
      auth_token = EnvHelper.env_or_error("TWILIO_API_KEY")

      begin
        client = Twilio::REST::Client.new(account_sid, auth_token)
        result = client.messages.create(
          from: @from,
          to:   @to,
          body: @body
        )
      rescue Twilio::REST::TwilioError => e
        return OpenStruct.new({success?: false, error: e.message})
      end

      # documentation is unclear on whether there are any errors that
      # do not throw an exception.
      if result.error_code.present?
        OpenStruct.new({success?: false, error: result.error_message})
      else
        OpenStruct.new({success?: true, payload: result.sid})
      end
    end

    def validate_message
      # TODO: check unsubscribe list or do not contact flag

      # check input
      if [@from, @to, @body].map(&:blank?).any?
        return OpenStruct.new({success?: false, error: "Missing from, to, or body"})
      end

      # safety to prevent sending texts to a patient outside of prod
      case Rails.env
      when "test"
        return OpenStruct.new({success?: false, error: "Can't send in test mode"})
      when "development"
        if MedarriveAdmin.where(phone_number: @phone_number).blank?
          return OpenStruct.new({success?: false, error: "SMS not sent in development mode"})
        end
      end

      OpenStruct.new({success?: true})
    end
  end
end
