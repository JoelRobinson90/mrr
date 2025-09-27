# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_partners
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  short_name      :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  alayacare_id    :integer
#  ma_id           :string           indexed
#
# Indexes
#
#  index_demand_partners_on_ma_id  (ma_id)
#
FactoryBot.define do
  factory :field_org do
    sequence(:name) {|n| "Labor Group #{n}" }
    slug { Faker::Internet.slug(glue: "_") }
  end
end
