# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: primary_care_physicians
#
#  id                  :bigint           not null, primary key
#  name                :string           not null
#  office_name         :string
#  office_phone_number :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class PrimaryCarePhysician < ApplicationRecord
  has_many :patients

  validates :name, presence: true

  def to_builder
    Jbuilder.new do |primary_care_physician|
      primary_care_physician.call(self, :id, :name, :office_phone_number, :office_name)
    end
  end
end
