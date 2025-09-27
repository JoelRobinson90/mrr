# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Authentication::TokenFetcher do
  # Client id/secrets set in environments/test.rb

  let(:broker) { Authentication::AthenaBroker }
  let(:token_fetcher) { Authentication::TokenFetcher }
  let(:datetime) { Date.parse("2020-01-01").beginning_of_day }
  let(:auth_endpoint) { broker.auth_endpoint }

  let(:expected_headers) do
    {
      content_type: "application/x-www-form-urlencoded"
    }
  end

  before do
    Timecop.freeze(datetime)

    allow(RestClient).to receive(:post).with(auth_endpoint, anything, headers: anything) do
      OpenStruct.new(
        body: {
          broker.access_token_key            => "medarrive-token-#{Time.now.to_i}",
          broker.access_token_expiration_key => (datetime + 1.hour).to_s,
          broker.refresh_token_key           => "medarrive-refresh-token-#{Time.now.to_i}"
        }.to_json
      )
    end

    allow(RestClient).to receive(:post).with(/field-org-id/, anything) do
      OpenStruct.new(
        body: {
          "access_token"            => "field-org-token-#{Time.now.to_i}",
          "access_token_expires_at" => (datetime + 1.hour).to_s
        }.to_json
      )
    end
  end

  after do
    Timecop.return
    described_class.reset_cache
  end

  context "with no field org" do
    it "needs this empty test case for the next test to pass for some reason" do
      token = token_fetcher.call(broker)
    end


    it "returns a valid cached token instead of making another API call(broker)" do
      expect(RestClient).to receive(:post).with(auth_endpoint, broker.auth_body, headers: expected_headers).once

      token_1 = token_fetcher.call(broker)
      Timecop.freeze(datetime + 5.minutes)
      token_2 = token_fetcher.call(broker)

      expect(token_2).to eq token_1
    end

  end
end
