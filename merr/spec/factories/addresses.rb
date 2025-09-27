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
FactoryBot.define do
  factory :address do
    address_line_one { Faker::Address.street_address }
    address_line_two { Faker::Address.secondary_address }
    city { Faker::Address.city }
    latitude  { Faker::Number.between(from: 31.024106, to: 48.481115) }
    longitude { Faker::Number.between(from: -124.086857, to: -81.215075) }
    notes { Faker::Lorem.paragraph }
    state { Faker::Address.state_abbr }
    zipcode { Faker::Address.zip_code }
    skip_geocoding { true }

    association :addressable, factory: :patient

    trait :florida do
      address_line_one { Faker::Address.street_address }
      address_line_two { Faker::Address.secondary_address }
      city { "Orlando" }
      state { "FL" }
      zipcode { "32789" }
      latitude { Faker::Number.normal(mean: 28.5383, standard_deviation: 0.05) }
      longitude { Faker::Number.normal(mean: -81.3792, standard_deviation: 0.05) }
      timezone { "America/New_York" }
    end

    trait :kentucky do
      address_line_one { Faker::Address.street_address }
      address_line_two { Faker::Address.secondary_address }
      city { "Louisville" }
      state { "KY" }
      zipcode { "40023" }
      latitude { Faker::Number.normal(mean: 38.2527, standard_deviation: 0.05) }
      longitude { Faker::Number.normal(mean: -85.7585, standard_deviation: 0.05) }
      timezone { "America/New_York" }
    end

    trait :los_angeles do
      address_line_one { Faker::Address.street_address }
      address_line_two { Faker::Address.secondary_address }
      city { "Los Angeles" }
      state { "CA" }
      zipcode { "90012" }
      latitude { Faker::Number.normal(mean: 34.061637, standard_deviation: 0.07) }
      longitude { Faker::Number.normal(mean: -118.249381, standard_deviation: 0.07) }
      timezone { "America/Los_Angeles" }
    end
  end
end
