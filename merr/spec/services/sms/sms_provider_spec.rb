# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sms::SmsProvider do
  describe "called" do
    context "with all data" do
      let(:message) { {from: "test", to: "test", body: "test"} }

      it "would send sms if not in test mode" do
        result = Sms::SmsProvider.call(message)

        expect(result[:error]).to eq("Can't send in test mode")
      end
    end

    context "with missing data" do
      let(:message) { {from: "", to: "", body: ""} }

      it "returns error" do
        result = Sms::SmsProvider.call(message)

        expect(result[:success?]).to be false
        expect(result[:error]).to eq("Missing from, to, or body")
      end
    end
  end
end
