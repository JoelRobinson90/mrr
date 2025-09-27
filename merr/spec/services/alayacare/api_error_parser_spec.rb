# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::Utils::ApiErrorParser do
  let(:service) { Alayacare::Utils::ApiErrorParser }

  describe "when parsing alayacare api errors" do
    let(:error_body) do
      "{\"code\":400,\"message\":\"Validation error.\",\"service_instructions\":[\"Field may not be null.\"]}\n"
    end
    it "should return string with errors from alayacare api" do
      error_parser = service.new(error_body)
      expect(error_parser.parsed_errors).to eq("service_instructions: Field may not be null.")
    end

    describe "when error body is different" do
      let(:error_body) { {code: 409, message: "Bad Request"} }
      it "should not fail if error body is nil" do
        error_parser = service.new(nil)
        expect(error_parser.parsed_errors).to eq("Something went wrong: ")
      end

      it "should display error message" do
        error_parser = service.new(error_body)
        expect(error_parser.parsed_errors).to eq "Bad Request"
      end
    end
  end
end
