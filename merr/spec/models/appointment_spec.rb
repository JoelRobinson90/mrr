# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: appointments
#
#  id                :bigint           not null, primary key
#  base_duration     :integer          default(30)
#  block_end_time    :datetime
#  block_start_time  :datetime
#  dispatch_notes    :text
#  drive_time        :float
#  end_time          :datetime
#  issue_reason      :string
#  route_index       :integer
#  start_time        :datetime
#  status            :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cohort_id         :integer
#  field_provider_id :bigint           indexed
#  patient_id        :bigint           indexed
#
# Indexes
#
#  index_appointments_on_field_provider_id  (field_provider_id)
#  index_appointments_on_patient_id         (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
require "rails_helper"

RSpec.describe Appointment, type: :model do
  context "validations" do
    it "enforces that its associated to a valid address" do
      no_address_appointment = build(:appointment, address: nil)
      bad_address_appointment = build(:appointment, address: build(:address, zipcode: nil))
      good_address_appointment = build(:appointment, address: build(:address))

      expect(no_address_appointment).to_not be_valid
      expect(bad_address_appointment).to_not be_valid
      expect(good_address_appointment).to be_valid
    end

    it "enforces valid status with custom message" do
      appointment = build(:appointment)
      time_stamp = Time.current
      appointment.status = "NO NO NO #{time_stamp}"

      expect(appointment).to_not be_valid
      expect(appointment.errors.full_messages).to eq(["Status NO NO NO #{time_stamp} is not a valid appointment status"])
    end
  end

  context "searching" do
    let(:appointment) { create(:appointment, patient: create(:patient, needs_hra_survey: false)) }

    it "finds appointment address" do
      expect(Appointment.search(appointment.address.address_line_one).map(&:id)).to include(appointment.id)
      expect(Appointment.search(appointment.address.address_line_two).map(&:id)).to include(appointment.id)
      expect(Appointment.search(appointment.address.state).map(&:id)).to include(appointment.id)
      expect(Appointment.search(appointment.address.city).map(&:id)).to include(appointment.id)
    end
  end

  context "duration" do
    let(:appointment) { create(:appointment, patient: create(:patient, needs_hra_survey: false)) }

    it "calculates duration" do
      # rules: 15 min per every two confirmed extra vaccine recipients plus 15 min for HRA
      appointment.extra_vaccine_recipients.update_all(confirmed: false)
      appointment.reload

      expect(appointment.duration).to eq(30)

      appointment.extra_vaccine_recipients.build(confirmed: true)
      expect(appointment.duration).to eq(45)

      appointment.extra_vaccine_recipients.build(confirmed: true)
      expect(appointment.duration).to eq(45)

      appointment.extra_vaccine_recipients.build(confirmed: true)
      expect(appointment.duration).to eq(60)

      appointment.patient.update(needs_hra_survey: true)
      expect(appointment.duration).to eq(75)
    end
  end

  describe "available_surveys" do
    let(:patient) { create :patient }
    let(:appointment) { create :appointment, patient: patient }
    let(:other_appointment) { create :appointment, patient: patient }

    let!(:unresponded_patient_survey) { create :survey, patient: patient }
    let!(:unresponded_appointment_survey) { create :survey, patient: patient, appointment: appointment }
    let!(:responded_appointment_survey) { create :survey, :responded, patient: patient, appointment: appointment }
    let!(:unresponded_survey_other_appointment) { create :survey, patient: patient, appointment: other_appointment }
    let!(:responded_survey_other_appointment) do
      create :survey, :responded, patient: patient, appointment: other_appointment
    end

    it "returns surveys belonging to the appointment, or unresponded surveys belonging to the patient that have no appointment" do
      available_survey_ids = appointment.available_surveys.pluck(:id)

      expected_appointment_ids = [
        unresponded_patient_survey,
        unresponded_appointment_survey,
        responded_appointment_survey
      ].map(&:id)
      expect(available_survey_ids).to eq expected_appointment_ids
    end
  end
end
