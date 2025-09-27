# == Schema Information
#
# Table name: patient_geos
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  geo_cohort_id   :bigint           not null, indexed
#  patient_id      :bigint           not null, indexed, indexed => [program_id]
#  program_id      :bigint           not null, indexed => [patient_id], indexed
#  service_area_id :bigint           not null, indexed
#
# Indexes
#
#  index_patient_geos_on_geo_cohort_id              (geo_cohort_id)
#  index_patient_geos_on_patient_id                 (patient_id)
#  index_patient_geos_on_patient_id_and_program_id  (patient_id,program_id) UNIQUE
#  index_patient_geos_on_program_id                 (program_id)
#  index_patient_geos_on_service_area_id            (service_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (geo_cohort_id => geo_cohorts.id)
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#  fk_rails_...  (service_area_id => service_areas.id)
#
class PatientGeo < ApplicationRecord
  belongs_to :patient
  belongs_to :program
  belongs_to :geo_cohort
  belongs_to :service_area
end
