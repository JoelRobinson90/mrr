# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_services
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  service_id :bigint           indexed => [visit_id], indexed => [visit_id]
#  visit_id   :bigint           indexed => [service_id], indexed => [service_id]
#
# Indexes
#
#  index_visit_services_on_service_id_and_visit_id  (service_id,visit_id)
#  index_visit_services_on_visit_id_and_service_id  (visit_id,service_id)
#
class VisitService < ApplicationRecord
  belongs_to :service
  belongs_to :visit
end
