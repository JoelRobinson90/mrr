# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: sms_templates
#
#  id                :bigint           not null, primary key
#  message_body      :string           not null
#  message_type      :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           not null, indexed
#
# Indexes
#
#  index_sms_templates_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
class SmsTemplate < ApplicationRecord
  belongs_to :demand_partner

  PATIENT_TYPES = %w[].freeze
  APPOINTMENT_TYPES = %w[confirmation update reminder followup].freeze

  validates :message_type, inclusion:  {in: PATIENT_TYPES + APPOINTMENT_TYPES},
                           uniqueness: {scope: :demand_partner}

  # Don't allow a body with curly brackets that don't have a % in front.
  validates :message_body, presence: true, format: {without: /(?<!%){/i,
                                                    message: "Can't have a curly bracket without %"}
end
