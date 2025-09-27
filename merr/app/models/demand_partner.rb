# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_partners
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  short_name      :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  alayacare_id    :integer
#  ma_id           :string           indexed
#
# Indexes
#
#  index_demand_partners_on_ma_id  (ma_id)
#
class DemandPartner < ApplicationRecord
  include OptionalPhysicalAddress

  has_many :patients
  has_many :programs
  has_many :sms_templates
  has_many :appointments, through: :patients
  has_many :visits, through: :patients
  has_many :external_accounts

  validates :name, presence: true
  validates :short_name, presence: true

  def get_athena_department(patient)
    tz = patient.address&.timezone
    generic_timezone = Address.convert_to_generic_timezone(tz)
    AthenaDepartment.find_by(demand_partner_id: id,
                             generic_timezone:  generic_timezone)
  end

  def to_builder
    Jbuilder.new do |demand_partner|
      demand_partner.call(self, :id, :name, :created_at, :updated_at)
    end
  end

  def to_s
    name
  end

  # Identifier methods

  def is_bright?
    name.include? "Bright"
  end

  def to_ma_object
    make_ma_object([:name])
  end
end
