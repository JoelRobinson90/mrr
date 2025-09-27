# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::Patient do
  let(:service) { Alayacare::Patient }

  describe "getting a patient by ID" do
    context "with an existing user ID, as a string or integer" do
      it "returns a patient object" do
        result = service.get("1002")
        parsed_body = JSON.parse(result.body, class_name: OpenStruct)
        expect(result.success?).to eq true
        expect(parsed_body).to have_key("id")
        expect(result.code).to eq 200

        result = service.get(1002)
        expect(result.success?).to eq true
        parsed_body = JSON.parse(result.body, class_name: OpenStruct)
        expect(parsed_body).to have_key("id")
        expect(result.code).to eq 200
      end
    end

    context "with a non-existent user ID" do
      it "returns an error message" do
        result = service.get("999")
        expect(result.success?).to eq false
        expect(result.code).to eq 404
      end
    end
  end

  describe "getting a patient by external ID" do
    context "with an existing external ID" do
      it "returns a patient object" do
        result = service.get_by_external_id("1234")
        parsed_body = JSON.parse(result.body, class_name: OpenStruct)
        expect(result.success?).to eq true
        expect(result.code).to eq 200
        expect(parsed_body["ac_id"]).to eq "AC000000409"
      end
    end

    context "with a non-existent e ID" do
      it "returns an error message" do
        result = service.get_by_external_id("nope")
        expect(result.success?).to eq false
        expect(result.code).to eq 404
      end
    end
  end
end
