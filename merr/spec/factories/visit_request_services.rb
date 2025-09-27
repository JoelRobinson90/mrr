# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_request_services
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  service_id       :bigint           not null, indexed, indexed => [visit_request_id], indexed => [visit_request_id]
#  visit_request_id :bigint           not null, indexed => [service_id], indexed, indexed => [service_id]
#
# Indexes
#
#  index_visit_request_services_on_service_id                       (service_id)
#  index_visit_request_services_on_service_id_and_visit_request_id  (service_id,visit_request_id)
#  index_visit_request_services_on_visit_request_id                 (visit_request_id)
#  index_visit_request_services_on_visit_request_id_and_service_id  (visit_request_id,service_id)
#
# Foreign Keys
#
#  fk_rails_...  (service_id => services.id)
#  fk_rails_...  (visit_request_id => visit_requests.id)
#
FactoryBot.define do
  factory :visit_request_service do
    association :visit_request
    association :service
  end
end
