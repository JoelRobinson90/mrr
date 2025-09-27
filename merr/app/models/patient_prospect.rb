# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: patient_prospects
#
#  id                    :bigint           not null, primary key
#  deleted_at            :datetime         indexed
#  diagnosis             :string           is an Array
#  discharge_end         :date
#  discharge_start       :date
#  medical_record_number :string
#  notes                 :string
#  preferred_language    :string
#  zipcode               :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  demand_partner_id     :bigint           indexed
#
# Indexes
#
#  index_patient_prospects_on_deleted_at         (deleted_at)
#  index_patient_prospects_on_demand_partner_id  (demand_partner_id)
#
class PatientProspect < ApplicationRecord
  acts_as_paranoid
  belongs_to :demand_partner

  include PgSearch::Model
  pg_search_scope :search, against: %i[
    medical_record_number
  ], using: {tsearch: {prefix: true}}

  validates :diagnosis, inclusion: {in: Patient::DIAGNOSES, allow_blank: true}, allow_nil: true

  # TODO: Is this a safe way to get who created it?
  # If so, we can move this to a common place
  def created_by
    whodunnit = versions.first.whodunnit
    User.where(id: whodunnit).first || whodunnit if whodunnit.present?
  end

  def to_builder
    Jbuilder.new do |json|
      json.call(self, :id, :diagnosis, :discharge_end, :discharge_start, :medical_record_number, :notes,
                :preferred_language, :zipcode, :created_at, :updated_at)
      json.demand_partner demand_partner.to_builder if demand_partner
      json.created_by created_by.to_builder if created_by
    end
  end
end
