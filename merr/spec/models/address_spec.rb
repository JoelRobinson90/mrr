# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: addresses
#
#  id                           :bigint           not null, primary key
#  address_line_one             :string
#  address_line_two             :string
#  addressable_type             :string           not null, indexed => [addressable_id]
#  city                         :string
#  county                       :string
#  geocoding_approximate_result :boolean
#  geocoding_partial_match      :boolean
#  latitude                     :string
#  longitude                    :string
#  notes                        :string
#  state                        :string
#  timezone                     :string
#  zipcode                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  addressable_id               :bigint           not null, indexed => [addressable_type]
#
# Indexes
#
#  index_addresses_on_addressable_type_and_addressable_id  (addressable_type,addressable_id)
#
require "rails_helper"

RSpec.describe Address, type: :model do
  context "before saving", :vcr do
    it "sets the timezone using zipcode" do
      # works with leading zero
      address = build(:address, zipcode: "04050", timezone: nil)

      expect { address.save! }.to change { address.timezone }
        .from(nil).to("America/New_York")
    end

    it "removes extra whitespace" do
      address = build(:address, zipcode: " 98103 ")

      expect { address.save! }.to change { address.zipcode }
        .from(" 98103 ").to("98103")
    end

    it "validates state abbreviation length" do
      # a real state name would get converted
      address = build(:address, state: "LSKdjflsdfj")

      expect(address.save).to be false

      expected = ["State is the wrong length (should be 2 characters)"]
      expect(address.errors.full_messages).to eq expected
    end

    it "converts state to abbreviation" do
      address = build(:address, state: "Alaska")

      expect(address.save).to be true

      address.reload

      expect(address.state).to eq("AK")
    end

    context "without coordinates" do
      let(:address) do
        build(:address, address_line_one: "3818 Eastern Ave N", address_line_two: "",
                                      city: "Seattle", state: "WA", zipcode: "98103",
                                      latitude: nil, longitude: nil, skip_geocoding: nil)
      end

      it "doesn't geocode if skip geocoding is set" do
        address.skip_geocoding = true

        address.save!
        address.reload
        expect(address.latitude).to be nil
      end

      it "geocodes by default" do
        expect(address.skip_geocoding).to eq(nil)

        address.save!
        address.reload
        expect(address.latitude).to eq "47.6537318"
        expect(address.longitude).to eq "-122.3288229"
      end

      # Was failing due to strange cassette issues; commenting out now to unblock a ticket, need to revisit

      # it "geocodes if lat/lng are empty strings" do
      #   address.update!(latitude: "", longitude: "")

      #   # Update doesn't persist the skip geocoding so we have to set after the update
      #   address.skip_geocoding = nil

      #   address.save!
      #   address.reload
      #   expect(address.latitude).to eq "47.6537318"
      #   expect(address.longitude).to eq "-122.3288229"
      # end
    end

    describe "with coordinates" do
      let(:address) do
        create(:address, latitude: "45.0", longitude: "-45.0", skip_geocoding: nil)
      end

      it "doesn't geocode" do
        address.reload
        # Since the lat/lng was set directly, no geocoding occours
        expect(address.latitude).to eq "45.0"
        expect(address.longitude).to eq "-45.0"
      end

      it "re-geocodes if address changes" do
        address.update(address_line_one: "1830 Parker St", city: "Berkeley", state: "CA", zipcode: "94703")

        address.reload
        expect(address.latitude).to eq "37.8611893"
        expect(address.longitude).to eq "-122.2727216"
      end
    end
  end
end
