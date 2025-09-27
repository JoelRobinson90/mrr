# typed: true
# frozen_string_literal: true

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
class HraSurvey < ApplicationRecord
  SURVEY_SCHEMA = {
    "type"  => "array",
    "items" => [
      {
        type:       "object",
        required:   %w[question answer],
        properties: {
          "question" => {
            "type" => "string"
          },
          "answer"   => {
            "type" => "string"
          }
        }
      }
    ]
  }.freeze

  belongs_to :patient

  validates :survey, schema: true
end
