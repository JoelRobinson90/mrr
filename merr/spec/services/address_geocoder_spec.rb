# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe AddressGeocoder do
  describe "runs on address", :vcr do
    context "without coordinates" do
      let(:address) do
        create(:address, address_line_one: "3818 Eastern Ave N", address_line_two: "",
                                       city: "Seattle", state: "WA", zipcode: "98103",
                                       latitude: nil, longitude: nil)
      end

      # TODO: enable after VCR fixed
      it "geocodes address" do
        address.skip_geocoding = false
        result = AddressGeocoder.call(address)
        expect(result.success?).to eq true

        expect(address.latitude).to eq "47.6537318"
        expect(address.longitude).to eq "-122.3288229"
        expect(address.geocoding_partial_match).to be false
        expect(address.geocoding_approximate_result).to be false
      end

      it "geocodes poorly formatted address" do
        address.update(address_line_one: "3818 Eastern", city: "SEA")

        address.skip_geocoding = false

        result = AddressGeocoder.call(address)
        expect(result.success?).to eq true

        expect(address.latitude).to eq "47.6537318"
        expect(address.longitude).to eq "-122.3288229"
        expect(address.geocoding_partial_match).to be true
        expect(address.geocoding_approximate_result).to be false
      end

      it "geocodes non-street address" do
        address.update(address_line_one: "Wallingford", city: "Seattle")

        address.skip_geocoding = false

        result = AddressGeocoder.call(address)
        expect(result.success?).to eq true

        expect(address.latitude).to eq "47.6600087"
        expect(address.longitude).to eq "-122.3425575"
        expect(address.geocoding_partial_match).to be false
        expect(address.geocoding_approximate_result).to be true
      end

      it "builds URL" do
        geocoder = AddressGeocoder.new(address)
        expected = "https://maps.googleapis.com/maps/api/geocode/json?address=3818+Eastern+Ave+N"\
                   "+Seattle+WA+98103&key=AIzaSyBepKqwdkNKFWWydPgtaxSJNUlpAR4h3fM"
        expect(geocoder.build_url).to eq expected
      end
    end
  end
end
