# frozen_string_literal: true

# == Schema Information
#
# Table name: services
#
#  id           :bigint           not null, primary key
#  duration     :integer          default(0), not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  alayacare_id :string
#  athena_id    :integer
#
class Service < ApplicationRecord
  has_many :program_services
  has_many :programs, through: :program_services

  # Don't allow deleting a service if it's attached to a visit.
  has_many :visit_services, dependent: :restrict_with_error
  has_many :visits, through: :visit_services

  has_many :visit_request_services
  has_many :visit_requests, through: :visit_request_services

  has_many :service_requests

  has_many :visit_type_services
  has_many :visit_types, through: :visit_type_services

  def to_builder
    Jbuilder.new do |service|
      service.call(self,
                   :id,
                   :name,
                   :alayacare_id,
                   :duration)
    end
  end

  def to_s
    name
  end
end
