# frozen_string_literal: true

# typed: true
require "twilio-ruby"

module Sms
  class SmsSender < ApplicationService
    def initialize(message_type, demand_partner, appointment, _provider = Sms::SmsProvider)
      @message_type = message_type
      @demand_partner = demand_partner
      @appointment = appointment
      @provider = _provider
      @substitutions = build_substitutions
    end

    def call
      # If the Patient does not consent to text messages, return failure with that information
      unless @appointment.patient.consent_to_text
        return OpenStruct.new({success?: false,
                               error:    "#{@appointment.patient.full_name} has not consented to Text Messages"})
      end

      render_result = render_template
      return render_result unless render_result.success?

      send_result = send_message
      return send_result unless send_result.success?

      log_result

      OpenStruct.new({success?: true})
    end

    def render_template
      template = SmsTemplate.where(demand_partner: @demand_partner, message_type: @message_type).first

      unless template
        return OpenStruct.new({success?: false,
                               error:    "No #{@message_type} template for #{@demand_partner.name}"})
      end

      begin
        @body = template.message_body % @substitutions
        OpenStruct.new({success?: true, payload: @body})
      rescue KeyError => e
        OpenStruct.new({success?: false, error: e.message})
      end
    end

    def send_message
      message = {from: EnvHelper.env_or_error("SMS_OUTBOUND_NUMBER"),
                 to:   @appointment.patient.phone_number,
                 body: @body}
      @result = @provider.call(message)
    end

    def log_result
      communication_log = CommunicationLog.new(
        body:               @body,
        communication_type: "SMS",
        context:            @appointment,
        destination:        @appointment.patient.phone_number,
        direction:          "outbound",
        event_trigger:      @message_type,
        patient:            @appointment.patient,
        reciept:            @result.payload || "sent with no reciept recieved"
      )

      unless communication_log.save
        # We don't want to return an error here because the message was successfully sent
        Rails.logger.error("SMS sent but communication_log did not save: #{communication_log.errors.full_messages.to_sentence}")
      end
    end

    def build_substitutions
      {
        date:           @appointment.start_time.to_date,
        start_time:     @appointment.start_time.strftime("%l:%M %p"),
        end_time:       @appointment.end_time.strftime("%l:%M %p"),
        first_name:     @appointment.patient.first_name,
        last_name:      @appointment.patient.last_name,
        full_name:      @appointment.patient.full_name,
        street_address: @appointment.address.address_line_one,
        full_address:   @appointment.address.pretty_print
      }
    end
  end
end
