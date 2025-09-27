# typed: true
# frozen_string_literal: true

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
class AvailabilitySlot < ApplicationRecord
  validates :day_of_week, inclusion: {in: Date::DAYNAMES}

  validates :start_hour, inclusion: {in: 8..20}
  validates :end_hour, inclusion:    {in: 8..20},
                       numericality: {greater_than: proc {|slot| slot.start_hour }}
end
