# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: pharmacies
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  patient_id   :bigint           not null, indexed
#
# Indexes
#
#  index_pharmacies_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :pharmacy do
    name { Faker::Company.name }
    phone_number { Faker::PhoneNumber.phone_number }
    association :patient
    association :address
  end
end
