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
require "rails_helper"

RSpec.describe Survey, type: :model do
  describe "response validation" do
    subject { build(:survey, response: response) }
    let(:response) { {} }

    context "empty response" do
      it { is_expected.to be_valid }
    end

    context "responses with q and a keys" do
      let(:response) do
        {
          question_id1: {
            q: "Question 1 text",
            a: "Answer 1 text"
          },
          question_id2: {
            q: "Question 2 text",
            a: "Answer 2 text"
          }
        }
      end

      it { is_expected.to be_valid }
    end

    context "old array-style response" do
      let(:response) do
        [
          {id: "question_id1", question: "question 1 text", answer: "answer 1 text"}
        ]
      end

      it { is_expected.not_to be_valid }
    end
  end
end
