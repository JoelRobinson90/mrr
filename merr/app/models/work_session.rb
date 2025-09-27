# == Schema Information
#
# Table name: work_sessions
#
#  id                 :bigint           not null, primary key
#  clock_in           :datetime         not null
#  clock_in_location  :string
#  clock_out          :datetime
#  clock_out_location :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  field_provider_id  :bigint           not null, indexed
#  visit_id           :bigint           not null, indexed
#
# Indexes
#
#  index_work_sessions_on_field_provider_id  (field_provider_id)
#  index_work_sessions_on_visit_id           (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_provider_id => field_providers.id)
#  fk_rails_...  (visit_id => visits.id)
#
class WorkSession < ApplicationRecord
  belongs_to :field_provider
  belongs_to :visit

  validates_presence_of :clock_in, :field_provider_id, :visit_id

  def display_name
    "#{clock_in} to #{clock_out || 'open'}"
  end
end
