# frozen_string_literal: true

# == Schema Information
#
# Table name: alayacare_form_answers
#
#  id                  :bigint           not null, primary key
#  approved_date       :string
#  field_tag           :string
#  processor           :string
#  question            :text
#  raw                 :text
#  reply               :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  alayacare_answer_id :string
#  response_id         :bigint           not null, indexed
#
# Indexes
#
#  alayacare_form_response_answer_index  (response_id)
#
# Foreign Keys
#
#  fk_rails_...  (response_id => alayacare_form_responses.id)
#
module AlayacareForm
  class Answer < ApplicationRecord

    belongs_to :response, class_name: "AlayacareForm::Response"
  end
end
