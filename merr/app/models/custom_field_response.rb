# frozen_string_literal: true

# == Schema Information
#
# Table name: custom_field_responses
#
#  id                             :bigint           not null, primary key
#  value                          :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  demand_partner_custom_field_id :bigint           indexed
#  patient_id                     :bigint           indexed
#  program_id                     :bigint           indexed
#
# Indexes
#
#  index_custom_field_responses_on_demand_partner_custom_field_id  (demand_partner_custom_field_id)
#  index_custom_field_responses_on_patient_id                      (patient_id)
#  index_custom_field_responses_on_program_id                      (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#
class CustomFieldResponse < ApplicationRecord
  belongs_to :demand_partner_custom_field, optional: false
  belongs_to :patient, optional: false
  belongs_to :program, optional: true

  validates :program, presence: true, if: :v2?

  delegate :v2?, to: :demand_partner_custom_field

  def to_builder
    Jbuilder.new do |custom_field_response|
      custom_field_response.call(self, :id, :value, :created_at, :updated_at)
      custom_field_response.demand_partner_custom_field do |demand_partner_custom_field|
        demand_partner_custom_field.display_name self.demand_partner_custom_field&.display_name
      end
    end
  end
end
