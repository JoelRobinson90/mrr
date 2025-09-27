# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: patients
#
#  id                             :bigint           not null, primary key
#  consent_to_email               :boolean          default(FALSE), not null
#  consent_to_text                :boolean          default(FALSE), not null
#  contact_email                  :string
#  date_of_birth                  :date
#  emergency_contact_name         :string
#  emergency_contact_phone_number :string
#  ethnicity                      :string
#  first_name                     :string
#  gender                         :string
#  last_name                      :string
#  medical_record_number          :string
#  middle_initial                 :string
#  needs_hra_survey               :boolean
#  patient_notes                  :text
#  phone_number                   :string
#  phone_number_type              :string
#  preferred_contact_method       :string
#  preferred_language             :string
#  preferred_pronouns             :string
#  primary_risk_category          :string
#  push_to_athena_error           :string
#  race                           :string
#  region                         :string
#  secondary_phone_number         :string
#  secondary_phone_number_type    :string
#  sex                            :string
#  status                         :string           default("Created"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  athena_id                      :integer
#  datalake_id                    :string
#  demand_partner_id              :bigint           not null, indexed
#  external_id                    :string           not null, indexed
#  ma_id                          :string           indexed
#  primary_care_physician_id      :bigint           indexed
#
# Indexes
#
#  index_patients_on_demand_partner_id          (demand_partner_id)
#  index_patients_on_external_id                (external_id) UNIQUE
#  index_patients_on_ma_id                      (ma_id)
#  index_patients_on_primary_care_physician_id  (primary_care_physician_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#  fk_rails_...  (primary_care_physician_id => primary_care_physicians.id)
#
FactoryBot.define do
  factory :patient do
    association :demand_partner
    date_of_birth { Faker::Date.between(from: "1900-01-01", to: "2015-01-01") }
    emergency_contact_name { Faker::Name.name }
    emergency_contact_phone_number { Faker::PhoneNumber.phone_number }
    first_name { Faker::Name.first_name }
    gender { Patient::GENDERS.sample }
    last_name { Faker::Name.last_name }
    medical_record_number { Faker::IDNumber.valid.gsub("-", "") }
    middle_initial { Faker::Alphanumeric.alpha(number: 1) }
    patient_notes { Faker::Lorem.paragraph }
    phone_number { Faker::PhoneNumber.cell_phone }
    consent_to_text { false }
    preferred_language { Patient::LANGUAGES_LONGFORM.sample }
    preferred_pronouns { Patient::PREFERRED_PRONOUNS.sample }
    secondary_phone_number { Faker::PhoneNumber.phone_number }
    sex { Patient::SEXES.sample }
    status { "Created" }
    ma_id { nil }

    trait :with_primary_care_physician do
      after(:build) do |record|
        record.primary_care_physician = create(:primary_care_physician)
      end
    end

    trait :with_user do
      after(:build) do |record|
        record.user = build(:user)
      end
    end

    trait :with_pharmacy do
      after(:build) do |record|
        record.pharmacies << build(:pharmacy, patient: record)
      end
    end

    trait :with_insurance do
      after(:build) do |record|
        record.insurances << build(:insurance, patient: record)
      end
    end

    trait :with_address do
      after(:build) do |record|
        record.address = build(:address, addressable: record)
      end
    end

    trait :with_la_address do
      after(:build) do |record|
        record.address = build(:address, :los_angeles, addressable: record)
      end
    end
  end
end
