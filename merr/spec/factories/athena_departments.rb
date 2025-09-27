# frozen_string_literal: true

# == Schema Information
#
# Table name: athena_departments
#
#  id                :bigint           not null, primary key
#  generic_timezone  :string           not null
#  name              :string           not null
#  timezone          :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  athena_id         :integer          not null
#  demand_partner_id :bigint           not null, indexed
#
# Indexes
#
#  index_athena_departments_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
FactoryBot.define do
  factory :athena_department do
    name { "Demand Partner (Eastern)" }
    timezone { "America/New_York" }
    generic_timezone { "EST/EDT" }
    athena_id { 1 }
    association :demand_partner, strategy: :build
  end
end
