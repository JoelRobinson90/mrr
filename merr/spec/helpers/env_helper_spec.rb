# frozen_string_literal: true

# typed: true
require "rails_helper"
require "cancan/matchers"

RSpec.describe EnvHelper do
  let(:env_key) { "KIPO_AND_THE_AGE_OF_WONDERBEASTS" }
  let(:env_value) { "DAVE_AND_BENSON" }

  context "env_or_nil" do
    it "returns nill on missing value" do
      ENV.delete(env_key)
      expect(ENV.key?(env_key)).to be_falsey

      expect(EnvHelper.env_or_nil(env_key)).to be_nil
    end

    it "returns value on found value" do
      ENV[env_key] = env_value
      expect(ENV.key?(env_key)).to be true

      expect(EnvHelper.env_or_nil(env_key)).to eq(env_value)
    end

    it "parses boolean values" do
      ENV[env_key] = "true"
      expect(EnvHelper.env_or_nil(env_key)).to be true

      ENV[env_key] = "false"
      expect(EnvHelper.env_or_nil(env_key)).to be false
    end
  end

  context "env_or_error" do
    it "raises error on missing value" do
      ENV.delete(env_key)
      expect(ENV.key?(env_key)).to be_falsey

      expect do
        EnvHelper.env_or_error(env_key)
      end.to raise_error
    end
    it "returns value on found value" do
      ENV[env_key] = env_value
      expect(ENV.key?(env_key)).to be true

      expect(EnvHelper.env_or_error(env_key)).to eq(env_value)
    end

    it "parses boolean values" do
      ENV[env_key] = "true"
      expect(EnvHelper.env_or_error(env_key)).to be true

      ENV[env_key] = "false"
      expect(EnvHelper.env_or_error(env_key)).to be false
    end
  end
end
