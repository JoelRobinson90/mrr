# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "db:seed" do
  it "does not raise an error" do
    expect { Rails.application.load_seed }.to_not raise_error
  end
end
