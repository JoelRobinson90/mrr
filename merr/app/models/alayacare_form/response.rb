# frozen_string_literal: true

# == Schema Information
#
# Table name: alayacare_form_responses
#
#  id                               :bigint           not null, primary key
#  alayacare_client_form_identifier :string
#  alayacare_client_identifier      :string
#  alayacare_form_identifier        :string
#  alayacare_service_identifier     :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  alayacare_patient_id             :string
#  alayacare_service_id             :string
#  appointment_id                   :bigint           indexed
#  patient_id                       :bigint           indexed
#  processed_file_id                :bigint
#
# Indexes
#
#  index_alayacare_form_responses_on_appointment_id  (appointment_id)
#  index_alayacare_form_responses_on_patient_id      (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_id => appointments.id)
#  fk_rails_...  (patient_id => patients.id)
#
module AlayacareForm
  class Response < ApplicationRecord
    belongs_to :patient, class_name: "::Patient", optional: true
    belongs_to :appointment, class_name: "::Appointment", optional: true

    has_many :answers, dependent: :destroy, class_name: "AlayacareForm::Answer"
  end
end
