# frozen_string_literal: true

# typed: true
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
require "rails_helper"

RSpec.describe ExtraVaccineRecipient, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
