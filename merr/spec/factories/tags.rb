# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  color          :string           default("#FFF"), not null
#  deleted_at     :datetime         indexed
#  description    :string
#  group          :string           default("Appointment"), not null
#  name           :string           indexed
#  taggings_count :integer          default(0)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_tags_on_deleted_at  (deleted_at)
#  index_tags_on_name        (name) UNIQUE
#
FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.sentence(word_count: 2) }

    color { Faker::Color.hex_color }

    description { Faker::Lorem.sentence }

    trait :for_appointment do
      group { "Appointment" }
    end

    trait :for_patient do
      group { "Patient" }
    end
  end
end
