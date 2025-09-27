# frozen_string_literal: true

# == Schema Information
#
# Table name: visits
#
#  id                       :bigint           not null, primary key
#  alayacare_status         :string
#  arrival_window_end       :datetime
#  arrival_window_start     :datetime
#  athena_telehealth_url    :string
#  canceled                 :boolean          default(FALSE)
#  confirmed                :boolean          default(FALSE)
#  end_time                 :datetime         not null
#  last_athena_sync         :string
#  push_to_alayacare_error  :string
#  push_to_athena_error     :string
#  reschedule_count         :integer
#  service_instructions     :string
#  start_time               :datetime         not null
#  status                   :string           default("scheduled")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  athena_encounter_id      :integer
#  athena_id                :integer
#  cancel_code_id           :bigint           indexed
#  external_id              :string           not null, indexed
#  field_provider_id        :bigint           indexed
#  ma_id                    :string           indexed
#  next_linked_visit_id     :integer
#  original_visit_id        :integer
#  patient_id               :bigint           not null, indexed
#  previous_linked_visit_id :integer
#  program_id               :bigint           not null, indexed
#  visit_group_id           :integer
#  visit_request_id         :bigint           indexed
#  visit_type_id            :bigint           not null, indexed
#
# Indexes
#
#  index_visits_on_cancel_code_id     (cancel_code_id)
#  index_visits_on_external_id        (external_id) UNIQUE
#  index_visits_on_field_provider_id  (field_provider_id)
#  index_visits_on_ma_id              (ma_id)
#  index_visits_on_patient_id         (patient_id)
#  index_visits_on_program_id         (program_id)
#  index_visits_on_visit_request_id   (visit_request_id)
#  index_visits_on_visit_type_id      (visit_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (cancel_code_id => cancel_codes.id)
#  fk_rails_...  (field_provider_id => field_providers.id)
#  fk_rails_...  (next_linked_visit_id => visits.id)
#  fk_rails_...  (original_visit_id => visits.id)
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (previous_linked_visit_id => visits.id)
#  fk_rails_...  (program_id => programs.id)
#  fk_rails_...  (visit_request_id => visit_requests.id)
#  fk_rails_...  (visit_type_id => visit_types.id)
#
FactoryBot.define do
  factory :visit do
    association :patient, strategy: :create
    association :visit_type, strategy: :create
    association :field_provider, strategy: :create
    program { association :program, strategy: :create, v2: v2_program }
    external_id { "Visit_#{SecureRandom.base58(16)}" }
    start_time { "2021-12-23 21:45:11" }
    end_time { "2021-12-23 21:45:11" }
    service_instructions { "Go around to back door" }

    transient do
      v2_program { false }
    end

    trait :v2 do
      v2_program { true }
    end
  end
end
