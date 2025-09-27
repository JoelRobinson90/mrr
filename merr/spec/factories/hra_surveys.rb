# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: hra_surveys
#
#  id         :bigint           not null, primary key
#  survey     :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  patient_id :bigint           not null, indexed
#
# Indexes
#
#  index_hra_surveys_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
FactoryBot.define do
  factory :hra_survey do
    survey { [{question: "What is your favourite colour?", answer: "Red.  No, wait..."}] }
    patient { create(:patient) }
  end
end
