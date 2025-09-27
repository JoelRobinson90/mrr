# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_types
#
#  id                :bigint           not null, primary key
#  duration          :integer          default(0), not null
#  name              :string           not null
#  outreach_visit    :boolean          default(FALSE)
#  plus_ones_enabled :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  alayacare_id      :string
#  athena_id         :integer
#  ma_id             :string           indexed
#  program_id        :bigint           indexed
#
# Indexes
#
#  index_visit_types_on_ma_id       (ma_id)
#  index_visit_types_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#
class VisitType < ApplicationRecord
  include PushToSalesforce

  has_many :visit_type_services, dependent: :destroy
  has_many :services, through: :visit_type_services
  has_many :visit_resource_requirements, dependent: :destroy

  has_many :visits, dependent: :restrict_with_error

  validates :name, presence: true
  validates :duration, presence: true

  has_many :program_visit_types, dependent: :destroy
  has_many :programs, through: :program_visit_types

  def to_builder(include_services = true)
    Jbuilder.new do |visit_type|
      visit_type.call(self,
                      :id,
                      :name,
                      :alayacare_id,
                      :duration,
                      :plus_ones_enabled)
      visit_type.services services.map {|s| s.to_builder.attributes! } if include_services
    end
  end

  def to_s
    name
  end

  def should_push_to_salesforce?
    true
  end

  def to_ma_object
    make_ma_object(%i[name duration outreach_visit plus_ones_enabled])
  end
end
