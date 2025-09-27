# == Schema Information
#
# Table name: visit_resources
#
#  id                :bigint           not null, primary key
#  end_time          :datetime         not null
#  in_home           :boolean          not null
#  start_time        :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  field_provider_id :bigint           indexed
#  visit_id          :bigint           indexed
#
# Indexes
#
#  index_visit_resources_on_field_provider_id  (field_provider_id)
#  index_visit_resources_on_visit_id           (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_provider_id => field_providers.id)
#  fk_rails_...  (visit_id => visits.id)
#
class VisitResource < ApplicationRecord
  belongs_to :visit
  belongs_to :field_provider

  def to_builder
    Jbuilder.new do |visit_resource|
      visit_resource.call(self,
                 :id,
                 :end_time,
                 :in_home,
                 :start_time,
                 :field_provider_id,
                 :visit_id)
      visit_resource.fp_external_id field_provider.external_id
    end
  end
end
