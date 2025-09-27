# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_type_services
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  service_id    :bigint           indexed => [visit_type_id]
#  visit_type_id :bigint           indexed => [service_id]
#
# Indexes
#
#  index_visit_type_services_on_visit_type_id_and_service_id  (visit_type_id,service_id)
#
class VisitTypeService < ApplicationRecord
  belongs_to :service
  belongs_to :visit_type
end
