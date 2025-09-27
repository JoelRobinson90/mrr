# == Schema Information
#
# Table name: service_areas
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ServiceArea < ApplicationRecord
  has_many :geo_cohorts
  
  has_many :patient_geos
  has_many :patients, through: :patient_geos

  def to_s
    name
  end
end
