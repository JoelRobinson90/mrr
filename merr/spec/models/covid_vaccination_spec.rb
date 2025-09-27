# frozen_string_literal: true

# typed: true
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
require "rails_helper"

RSpec.describe CovidVaccination, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
