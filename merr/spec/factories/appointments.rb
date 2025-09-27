# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: appointments
#
#  id                :bigint           not null, primary key
#  base_duration     :integer          default(30)
#  block_end_time    :datetime
#  block_start_time  :datetime
#  dispatch_notes    :text
#  drive_time        :float
#  end_time          :datetime
#  issue_reason      :string
#  route_index       :integer
#  start_time        :datetime
#  status            :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cohort_id         :integer
#  field_provider_id :bigint           indexed
#  patient_id        :bigint           indexed
#
# Indexes
#
#  index_appointments_on_field_provider_id  (field_provider_id)
#  index_appointments_on_patient_id         (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
FactoryBot.define do
  factory :appointment do
    block_start_time { Faker::Time.between(from: Date.tomorrow, to: 1.week.from_now.end_of_day).beginning_of_hour }
    block_end_time { block_start_time + 1.hour }
    start_time { Faker::Time.between(from: block_start_time, to: block_start_time + 30.minutes) }
    end_time { start_time ? Faker::Time.between(from: start_time + 15.minutes, to: start_time + 45.minutes) : nil }
    status { "Assigned" }
    address { build(:address, %i[florida kentucky].sample) }

    trait :with_extra_recipients do
      after(:build) do |record|
        record.covid_vaccination = build(:covid_vaccination, appointment: record)
        record.extra_vaccine_recipients << build(:extra_vaccine_recipient, appointment: record)
      end
    end

    association :patient
    association :field_provider

    trait :created do
      status { "Created" }
    end

    trait :assigned do
      status { "Assigned" }
    end
  end
end
