# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_requests
#
#  id           :bigint           not null, primary key
#  cancelled_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :bigint           not null, indexed
#  patient_id   :bigint           not null, indexed
#  program_id   :bigint           not null, indexed
#
# Indexes
#
#  index_visit_requests_on_creator_id  (creator_id)
#  index_visit_requests_on_patient_id  (patient_id)
#  index_visit_requests_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#
class VisitRequest < ApplicationRecord
  belongs_to :program
  belongs_to :patient
  belongs_to :creator, class_name: "User"

  has_many :visit_request_services
  has_many :services, through: :visit_request_services
  has_one :visit

  # TODO: when linked to the new Visit model, filter out records with a visit
  scope :pending, -> { with_statuses.where(cancelled_at: nil) }

  # TODO: preload all necessary associations to determine status
  scope :with_statuses, -> { self }

  validate :match_patient_demand_partner
  def match_patient_demand_partner
    if program&.demand_partner_id != patient&.demand_partner_id
      errors.add(:patient, "does not belong to the program partner")
    end
  end

  # TODO: when linked to the new Visit model, check its existence/status and return here
  STATUSES = %i[pending scheduled complete cancelled].freeze
  def status
    return :cancelled if cancelled_at
    return :complete if visit&.end_time&.past?
    return :scheduled if visit

    :pending
  end
end
