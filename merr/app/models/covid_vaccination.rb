# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: covid_vaccinations
#
#  id               :bigint           not null, primary key
#  dose             :string
#  expire           :datetime
#  lot              :string
#  reaction         :boolean          default(FALSE), not null
#  reaction_notes   :text
#  route            :string
#  site             :string
#  vaccine_quantity :integer          default(1), not null
#  vaccine_type     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  appointment_id   :bigint           not null, indexed
#
# Indexes
#
#  index_covid_vaccinations_on_appointment_id  (appointment_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_id => appointments.id)
#
class CovidVaccination < ApplicationRecord
  include CovidVaccinationConstants
  include VaccinePaperTrail
  
  belongs_to :appointment
  has_one :extra_vaccine_recipient, required: false

  validates :vaccine_type, inclusion: {in: CovidVaccination::VACCINE_TYPES_VALIDATION}, allow_blank: true
  validates :route, inclusion: {in: VACCINE_ROUTE}, allow_blank: true
  validates :site, inclusion: {in: VACCINE_INJECTION_SITE}, allow_blank: true
  validates :dose, inclusion: {in: VACCINE_DOSE}, allow_blank: true

  def to_s
    self.appointment_patient_name
  end

  def papertrail_display_name
    if extra_vaccine_recipient.present?
      extra_vaccine_recipient.papertrail_display_name
    else
      self.appointment_patient_name
    end
  end

  def appointment_patient_name
    self.appointment&.patient&.display_name
  end

  def to_builder
    Jbuilder.new do |covid_vaccination|
      covid_vaccination.call(
        self,
        :id,
        :reaction,
        :reaction_notes,
        :vaccine_type,
        :lot,
        :expire,
        :dose,
        :route,
        :site,
      )
    end
  end
end
