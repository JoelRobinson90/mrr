# frozen_string_literal: true

# typed: true
class AddressGeocoder < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    result = RestClient.get(build_url)
    return OpenStruct.new({success?: false, error: "Could not geocode address"}) unless result.code == 200

    body = JSON.parse(result.body)

    return OpenStruct.new({success?: false, error: "Could not save address"}) unless save_address(body)

    OpenStruct.new({success?: true, message: "#{@address.latitude},#{@address.longitude}"})
  end

  def build_url
    url_base = "https://maps.googleapis.com/maps/api/geocode/json"
    token = "AIzaSyBepKqwdkNKFWWydPgtaxSJNUlpAR4h3fM"
    safe_address = CGI.escape("#{@address.address_line_one} #{@address.city} #{@address.state} #{@address.zipcode}")

    "#{url_base}?address=#{safe_address}&key=#{token}"
  end

  def save_address(body)
    coords = body.dig("results", 0, "geometry", "location")
    partial = !body.dig("results", 0, "partial_match").nil?
    approximate = %w[GEOMETRIC_CENTER APPROXIMATE].include? body.dig("results", 0, "geometry", "location_type")

    return false if coords.blank?

    @address.assign_attributes(longitude:                    coords["lng"],
                               latitude:                     coords["lat"],
                               geocoding_partial_match:      partial,
                               geocoding_approximate_result: approximate)

    true
  end
end
