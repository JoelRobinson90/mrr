# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sms::SmsSender do
  let(:demand_partner) { create(:demand_partner) }
  let(:appointment) do
    create(:appointment, patient: create(:patient, first_name:      "Bob",
                                                   consent_to_text: true))
  end
  let(:sms_template) do
    create(:sms_template, demand_partner: demand_partner,
                              message_type: "confirmation", message_body: "Test %{first_name}")
  end

  describe "render template" do
    context "with all data" do
      it "fills in data" do
        sender = Sms::SmsSender.new(sms_template.message_type, sms_template.demand_partner, appointment)
        render_result = sender.render_template
        expect(render_result.success?).to be true
        expect(render_result.payload).to eq("Test Bob")
      end
    end

    context "with missing data" do
      let(:sms_template) do
        create(:sms_template, demand_partner: demand_partner,
                                  message_type: "confirmation", message_body: "Test %{bad_key}")
      end
      it "returns KeyError" do
        sender = Sms::SmsSender.new(sms_template.message_type, sms_template.demand_partner, appointment)
        render_result = sender.render_template

        expect(render_result[:success?]).to be false
        expect(render_result[:error]).to eq("key{bad_key} not found")
      end
    end
  end

  describe "sends with mocked provider" do
    it "does not send to patient without consent" do
      appointment.patient.update(consent_to_text: false)
      result = Sms::SmsSender.call(sms_template.message_type, sms_template.demand_partner,
                                   appointment)

      expect(result).to eq(OpenStruct.new({success?: false,
                                           error:    "#{appointment.patient.full_name} has not consented to Text Messages"}))
    end

    it "logs result" do
      expect(Sms::SmsProvider).to receive(:call).and_return(OpenStruct.new({success?: true, payload: "test_sid"}))

      result = Sms::SmsSender.call(sms_template.message_type, sms_template.demand_partner,
                                   appointment)

      expect(result.success?).to be true

      log = CommunicationLog.last

      expect(log.context).to eq(appointment)
      expect(log.reciept).to eq("test_sid")
    end
  end
end
