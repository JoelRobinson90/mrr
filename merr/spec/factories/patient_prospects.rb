# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: patient_prospects
#
#  id                    :bigint           not null, primary key
#  deleted_at            :datetime         indexed
#  diagnosis             :string           is an Array
#  discharge_end         :date
#  discharge_start       :date
#  medical_record_number :string
#  notes                 :string
#  preferred_language    :string
#  zipcode               :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  demand_partner_id     :bigint           indexed
#
# Indexes
#
#  index_patient_prospects_on_deleted_at         (deleted_at)
#  index_patient_prospects_on_demand_partner_id  (demand_partner_id)
#
FactoryBot.define do
  factory :patient_prospect do
    medical_record_number { Faker::IDNumber.valid.gsub("-", "") }
    association :demand_partner
    zipcode { Faker::Address.zip_code }
    discharge_start { 1.week.from_now.to_date }
    discharge_end { 2.weeks.from_now.to_date }
    diagnosis { "Diabetes" }
    preferred_language { "Spanish" }
    notes { "Patient is hard of hearing" }
  end
end
