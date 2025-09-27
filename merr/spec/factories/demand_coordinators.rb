# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: demand_coordinators
#
#  id                :bigint           not null, primary key
#  first_name        :string
#  last_name         :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           not null, indexed
#
# Indexes
#
#  index_demand_coordinators_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
FactoryBot.define do
  factory :demand_coordinator do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    association :demand_partner

    after :build do |record|
      record.user = FactoryBot.create(:user, account: record) unless record.user
    end
  end
end
