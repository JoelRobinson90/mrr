# typed: true
# frozen_string_literal: true

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
require Rails.root.join("lib/zip_to_timezone")

class Address < ApplicationRecord
  include PgSearch::Model
  include AddressConstants

  belongs_to :addressable, polymorphic: true
  validates :address_line_one, :city, :state, :zipcode, presence: true
  validates :state, length: {is: 2}

  before_validation :format_state
  before_save :strip_whitespace
  before_save :lookup_timezone
  before_save :geocode_address, if: proc {|address| !address.skip_geocoding }

  attr_accessor :skip_geocoding

  class << self
    def convert_to_generic_timezone(tz_str)
      tz = begin
        TZInfo::Timezone.get(tz_str)
      rescue StandardError
        nil
      end
      winter = tz&.abbreviation(Time.zone.local(2023, 1, 1))
      summer = tz&.abbreviation(Time.zone.local(2023, 6, 1))

      generic = [winter, summer].uniq.compact.join("/")
      return nil if generic.blank?

      generic
    end
  end

  def single_address_line
    [address_line_one, address_line_two].filter(&:present?).join(", ")
  end

  def pretty_print
    "#{single_address_line}, #{city} #{state}, #{zipcode}"
  end
  alias display_name pretty_print

  def in_service_area?
    true
  end

  def to_builder
    Jbuilder.new do |address|
      address.call(self, :id, :address_line_one, :address_line_two, :city,
                   :latitude, :longitude, :notes, :state, :zipcode,
                   :display_name, :county, :timezone)
    end
  end

  def country
    # TODO: Replace this with real country
    "USA"
  end

  private

  def strip_whitespace
    self.zipcode = zipcode.strip
  end

  def lookup_timezone
    self.timezone = ZipToTimezone.convert(zipcode)
  end

  def format_state
    # Try and lookup state abbreviation if not already abbreviated.
    self.state = STATE_ABBREVIATIONS[state] || state if state.length != 2
  end

  def geocode_address
    # We don't want to geocode without a specific address
    return if address_line_one.blank?

    # Don't geocode if lat and long have just been assigned (e.g. when duplicating address).
    return if latitude.present? && longitude.present? && (changed & %w[latitude longitude]).any?

    AddressGeocoder.call(self)
  end
end
