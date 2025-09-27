# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_requests
#
#  id           :bigint           not null, primary key
#  cancelled_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :bigint           not null, indexed
#  patient_id   :bigint           not null, indexed
#  program_id   :bigint           not null, indexed
#
# Indexes
#
#  index_visit_requests_on_creator_id  (creator_id)
#  index_visit_requests_on_patient_id  (patient_id)
#  index_visit_requests_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#
FactoryBot.define do
  factory :visit_request do
    transient do
      transient_demand_partner { build(:demand_partner) }
    end

    program { build :program, demand_partner: transient_demand_partner }
    patient { build :patient, demand_partner: transient_demand_partner }
    creator { build :demand_coordinator_user, demand_partner: transient_demand_partner }
    services { build_list :service, 2, programs: [program] }
    cancelled_at { nil }

    trait :cancelled do
      cancelled_at { 1.day.ago }
    end
  end
end
