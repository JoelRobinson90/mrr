# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: availability_slots
#
#  id          :bigint           not null, primary key
#  day_of_week :string           not null
#  end_hour    :integer          not null
#  start_hour  :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :availability_slot do
    day_of_week { Date::DAYNAMES.sample }
    start_hour { rand(8..19) }
    end_hour { start_hour + 1 }
  end
end
