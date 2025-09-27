# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :demand_partner do
    sequence(:name) {|n| "Hospital #{n}" }
    sequence(:short_name) {|n| "Hospital#{n}" }
    sequence(:ma_id) {|n| "spec_demandPartner_#{n}" }
  end
end
