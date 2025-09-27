# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  appointment_id    :bigint           indexed
#  demand_partner_id :bigint           not null, indexed
#  patient_id        :bigint           not null, indexed
#
# Indexes
#
#  index_orders_on_appointment_id     (appointment_id)
#  index_orders_on_demand_partner_id  (demand_partner_id)
#  index_orders_on_patient_id         (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_id => appointments.id)
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#  fk_rails_...  (patient_id => patients.id)
#
class Order < ApplicationRecord

  belongs_to :patient, optional: false
  belongs_to :demand_partner, optional: false
  belongs_to :appointment, optional: false
  accepts_nested_attributes_for :appointment

  class << self
  end

  def has_results
    false
  end

end
