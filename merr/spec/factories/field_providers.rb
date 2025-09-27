# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: field_providers
#
#  id                      :bigint           not null, primary key
#  bio                     :string
#  date_of_birth           :date
#  first_name              :string
#  last_name               :string
#  license_number          :string
#  phone                   :string
#  provider_level          :string
#  push_to_wheniwork_error :string
#  role                    :string           default("field_provider")
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  athena_id               :integer
#  external_id             :string           not null, indexed
#  field_org_id            :bigint           not null, indexed
#  ma_id                   :string           indexed
#
# Indexes
#
#  index_field_providers_on_external_id   (external_id) UNIQUE
#  index_field_providers_on_field_org_id  (field_org_id)
#  index_field_providers_on_ma_id         (ma_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_org_id => field_orgs.id)
#
FactoryBot.define do
  factory :field_provider do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    provider_level { "Paramedic" }
    external_id { "FieldProvider_#{SecureRandom.base58(16)}" }

    association :field_org, strategy: :create
    association :address

    after :build do |record|
      record.user = FactoryBot.create(:field_provider_user, account: record) unless record.user
    end

    trait :with_appointments do
      after(:build) do |record|
        record.appointments << build(:appointment, field_provider: record)
      end
    end
  end
end
