# frozen_string_literal: true

FactoryBot.define do
  factory :visit_event do
    event_type { "clocked_in" }
    time { "2021-12-23 21:45:11" }
    association :field_provider, strategy: :create
    association :visit, strategy: :create
  end
end
