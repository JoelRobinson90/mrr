# frozen_string_literal: true

# == Schema Information
#
# Table name: provider_preferences
#
#  id                :bigint           not null, primary key
#  source            :string           default("care_team"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  field_provider_id :bigint           not null, indexed
#  patient_id        :bigint           not null, indexed
#
# Indexes
#
#  index_provider_preferences_on_field_provider_id  (field_provider_id)
#  index_provider_preferences_on_patient_id         (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_provider_id => field_providers.id)
#  fk_rails_...  (patient_id => patients.id)
#
class ProviderPreference < ApplicationRecord
  belongs_to :patient
  belongs_to :field_provider

  delegate :role, to: :field_provider
end
