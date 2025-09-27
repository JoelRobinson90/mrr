# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: pharmacies
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  patient_id   :bigint           not null, indexed
#
# Indexes
#
#  index_pharmacies_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id) ON DELETE => cascade
#
class Pharmacy < ApplicationRecord
  include RequiredPhysicalAddress
  belongs_to :patient

  validates :name, presence: true

  def to_builder
    Jbuilder.new do |pharmacy|
      pharmacy.call(self,
                    :id,
                    :name,
                    :phone_number)
      pharmacy.address do |address|
        address.display_name self.address&.display_name
      end
    end
  end
end
