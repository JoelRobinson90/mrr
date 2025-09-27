# == Schema Information
#
# Table name: geo_cohorts
#
#  id              :bigint           not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  service_area_id :bigint           not null, indexed
#
# Indexes
#
#  index_geo_cohorts_on_service_area_id  (service_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (service_area_id => service_areas.id)
#
class GeoCohort < ApplicationRecord
  belongs_to :service_area

  has_many :patient_geos
  has_many :patients, through: :patient_geos

  def to_s
    name
  end
end
