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
FactoryBot.define do
  factory :work_session do
    clock_in { "2022-10-23 23:40:47" }
    clock_out { "2022-10-23 23:40:47" }
    clock_in_location { "45.518,-73.582" }
    clock_out_location { "45.518,-73.582" }
    association :field_provider, strategy: :create
    association :visit, strategy: :create
  end
end
