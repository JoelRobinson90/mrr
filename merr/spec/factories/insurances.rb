# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: insurances
#
#  id               :bigint           not null, primary key
#  bin_number       :string
#  effective_date   :date
#  name             :string
#  plan_description :text
#  renewal_date     :date
#  rx_group         :string
#  rx_pcn           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  group_id         :string
#  member_id        :string
#  patient_id       :bigint           not null, indexed
#
# Indexes
#
#  index_insurances_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :insurance do
    association :patient
    group_id { Faker::IDNumber.valid.gsub(" ", "") }
    member_id { Faker::IDNumber.valid }
    name { Faker::Company.name }
    bin_number { Faker::Number.number(digits: 6).to_s }
    plan_description { Faker::Lorem.paragraph }
    effective_date { Faker::Date.between(from: "2015-01-01", to: "2020-01-01") }
    renewal_date { Faker::Date.between(from: "2020-01-01", to: "2025-01-01") }
    rx_pcn { Faker::IDNumber.valid }
    rx_group { Faker::IDNumber.valid }
  end
end
