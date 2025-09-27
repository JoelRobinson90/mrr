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
require "rails_helper"

RSpec.describe HraSurvey, type: :model do
  context "validations" do
    it "expects survey without data to not be valid" do
      no_survey_data = build(:hra_survey, survey: nil)

      expect(no_survey_data).to_not be_valid
    end

    it "expects JSON data to match schema" do
      good_survey_data = build(:hra_survey)

      expect(good_survey_data).to be_valid
    end

    it "expects bad JSON data to not be valid" do
      bad_survey_data = build(:hra_survey, survey: [{dude: 4}])

      expect(bad_survey_data).to_not be_valid
    end

    it "expects missing question to not be valid" do
      no_question_survey = build(:hra_survey, survey: [{notAQuestion: "test", answer: "test"}])

      expect(no_question_survey).to_not be_valid
    end

    it "expects missing answer to not be valid" do
      no_answer_survey = build(:hra_survey, survey: [{question: "test", notAnAnswer: "test"}])

      expect(no_answer_survey).to_not be_valid
    end

    it "expects a survey response with only questions to not be valid" do
      only_question_survey = build(:hra_survey, survey: [{question: "test"}])

      expect(only_question_survey).to_not be_valid
    end

    it "expects a survey response with only answers to not be valid" do
      only_answer_survey = build(:hra_survey, survey: [{answer: "test"}])

      expect(only_answer_survey).to_not be_valid
    end
  end
end
