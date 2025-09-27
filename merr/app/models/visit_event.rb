# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_events
#
#  id                :bigint           not null, primary key
#  event_type        :string
#  location          :string
#  time              :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  field_provider_id :bigint           not null, indexed
#  visit_id          :bigint           not null, indexed
#
# Indexes
#
#  index_visit_events_on_field_provider_id  (field_provider_id)
#  index_visit_events_on_visit_id           (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_provider_id => field_providers.id)
#  fk_rails_...  (visit_id => visits.id)
#
class VisitEvent < ApplicationRecord
  belongs_to :field_provider
  belongs_to :visit

  enum event: {en_route: 0, on_site: 1, clocked_in: 2, completed: 3}

  def display_name
    "#{event_type} at #{time}"
  end
end
