# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kustomer::CustomerService, type: :request do
  let(:customer_id) { "603eb78fb656472653bb9b26" }
  let(:service) { Kustomer::CustomerService }

  describe "getting a patient by ID" do
    context "with an existing user ID, as a string or integer" do
      # Ignoring test as VCR is currency not functioning as expected
      xit "returns a patient object" do
        result = service.call(customer_id)
        expect(result.success?).to eq true
        expect(result.body.dig("data", "id")).not_to be_nil
        expect(result.code).to eq 200
      end
    end

    context "with a non-existent user ID" do
      # Ignoring test as VCR is currency not functioning as expected
      xit "returns an error message" do
        result = service.call("999")
        expect(result.success?).to eq false
        expect(result.code).to eq 400
      end
    end
  end
end
