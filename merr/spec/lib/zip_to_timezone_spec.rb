require "rails_helper"
require "#{Rails.root}/lib/zip_to_timezone"

RSpec.describe ZipToTimezone do
  subject { ZipToTimezone.convert(zip) }

  describe "5 digit zipcode" do
    let(:zip) { "10024" }
    it { is_expected.to eq "America/New_York" }
  end

  describe "longer zipcode" do
    let(:zip) { "10024-5678" }
    it { is_expected.to eq "America/New_York" }
  end

  describe "zipcode with leading zeros" do
    let(:zip) { "03266" }
    it { is_expected.to eq "America/New_York" }
  end
end
