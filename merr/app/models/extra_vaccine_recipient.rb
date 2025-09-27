# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: extra_vaccine_recipients
#
#  id                         :bigint           not null, primary key
#  complete                   :boolean          default(FALSE)
#  confirmed                  :boolean          default(FALSE)
#  consent_to_text            :boolean          default(FALSE)
#  date_of_birth              :date
#  deleted                    :boolean          default(FALSE)
#  ethnicity                  :string
#  name                       :string
#  phone_number               :string
#  race                       :string
#  unable_to_vaccinate        :string
#  unable_to_vaccinate_reason :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  appointment_id             :bigint           not null, indexed
#  covid_vaccination_id       :bigint           indexed
#
# Indexes
#
#  index_extra_vaccine_recipients_on_appointment_id        (appointment_id)
#  index_extra_vaccine_recipients_on_covid_vaccination_id  (covid_vaccination_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_id => appointments.id)
#  fk_rails_...  (covid_vaccination_id => covid_vaccinations.id)
#
class ExtraVaccineRecipient < ApplicationRecord
  include FormattedPhoneNumber
  include FormattedDateOfBirth
  include VaccinePaperTrail

  default_scope { where(deleted: false) }

  belongs_to :appointment

  validates :name, presence: true

  belongs_to :covid_vaccination, optional: true

  accepts_nested_attributes_for :covid_vaccination
  
  def trailed_related_content
    [covid_vaccination]
  end

  def papertrail_display_name
    self.name
  end

  def to_s
    id
  end

  def to_builder
    Jbuilder.new do |extra_vaccine_recipient|
      extra_vaccine_recipient.call(self, :id, :complete, :confirmed, :consent_to_text, :name, :race, :ethnicity,
                                   :unable_to_vaccinate, :unable_to_vaccinate_reason)
      extra_vaccine_recipient.phone_number display_phone_number
      extra_vaccine_recipient.date_of_birth display_date_of_birth
      extra_vaccine_recipient.covid_vaccination covid_vaccination
      extra_vaccine_recipient.is_complete complete || unable_to_vaccinate == "No"
    end
  end
end
