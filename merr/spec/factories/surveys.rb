# frozen_string_literal: true

# == Schema Information
#
# Table name: surveys
#
#  id             :bigint           not null, primary key
#  name           :string           not null, indexed
#  responded_at   :datetime
#  response       :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  appointment_id :bigint           indexed
#  patient_id     :bigint           not null, indexed
#
# Indexes
#
#  index_surveys_on_appointment_id  (appointment_id)
#  index_surveys_on_name            (name)
#  index_surveys_on_patient_id      (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_id => appointments.id)
#  fk_rails_...  (patient_id => patients.id)
#
FactoryBot.define do
  factory :survey do
    name { Survey::SURVEY_NAMES.first }
    association :patient

    trait :responded do
      response do
        {
          "like_medarrive" => {
            "q" => "Do you like MedArrive?",
            "a" => "Yes"
          },
          "other_concerns" => {
            "q" => "Do you have any other concerns?",
            "a" => "No"
          }
        }
      end
      responded_at { 1.day.ago }
    end
  end
end
