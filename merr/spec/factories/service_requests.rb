# == Schema Information
#
# Table name: service_requests
#
#  id             :bigint           not null, primary key
#  refusal_reason :string
#  status         :string           default("requested"), not null
#  status_detail  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  ma_id          :string           not null, indexed
#  patient_id     :bigint           not null, indexed => [program_id, service_id]
#  program_id     :bigint           not null, indexed, indexed => [patient_id, service_id]
#  service_id     :bigint           not null, indexed, indexed => [patient_id, program_id]
#
# Indexes
#
#  index_service_requests_on_ma_id        (ma_id)
#  index_service_requests_on_program_id   (program_id)
#  index_service_requests_on_service_id   (service_id)
#  patient_program_service_request_index  (patient_id,program_id,service_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#  fk_rails_...  (service_id => services.id)
#
FactoryBot.define do
  factory :service_request do
    sequence(:ma_id) {|n| "spec_ServiceRequest_#{n}" }
    association :patient, strategy: :build
    association :program, strategy: :build
    association :service, strategy: :build
    status { "requested" }
    status_detail { nil }
  end
end
