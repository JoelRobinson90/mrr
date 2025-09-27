# frozen_string_literal: true

# == Schema Information
#
# Table name: services
#
#  id           :bigint           not null, primary key
#  duration     :integer          default(0), not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  alayacare_id :string
#  athena_id    :integer
#
FactoryBot.define do
  factory :service do
    name { Faker::Lorem.sentence(word_count: 2) }
    alayacare_id { Faker::Number.number(digits: 6).to_s }
  end
end
