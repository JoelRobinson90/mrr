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
class Survey < ApplicationRecord
  CLOVER_CARE_VISIT = "clover_care_visit"
  CLOVER_IN_HOME_CARE = "clover_in_home_care"
  CLOVER_CARE_VISIT_AND_IN_HOME_CARE = "clover_care_visit_and_in_home_care"

  SURVEY_NAMES = [
    CLOVER_CARE_VISIT,
    CLOVER_IN_HOME_CARE,
    CLOVER_CARE_VISIT_AND_IN_HOME_CARE
  ].freeze

  RESPONSE_SCHEMA = {
    "type"              => "object",
    "patternProperties" => {
      ".*" => {
        type:       "object",
        required:   %w[q],
        properties: {
          "q" => {
            "type" => "string"
          },
          "a" => {
            "type" => "string"
          }
        }
      }
    }
  }.freeze

  belongs_to :patient
  belongs_to :appointment, optional: true

  validates :name, inclusion: {in: SURVEY_NAMES}
  validates :response, schema: true

  scope :responded, -> { where.not(responded_at: nil) }
  scope :not_responded, -> { where(responded_at: nil) }

  def responded?
    response.present?
  end

  def meta
    yaml_data["meta"]
  end

  def template
    yaml_data["template"]
  end

  def to_builder(include_response: false, include_template: false)
    Jbuilder.new do |survey|
      survey.call(self, :id, :name, :responded_at, :meta)
      survey.responded responded?

      survey.response response if include_response

      survey.template template if include_template
    end
  end

  private

  def yaml_data
    @yaml_data ||= YAML.safe_load(File.read(Rails.root.join("lib", "data", "surveys", "#{name}.yml")))
  end
end
