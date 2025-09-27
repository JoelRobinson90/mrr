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
require "rails_helper"

RSpec.describe AvailabilitySlot, type: :model do
  let(:slot) { create(:availability_slot) }

  it "Won't accept bad time" do
    slot.start_hour = 30

    expect(slot.valid?).to be false

    # must be minimum to avoid flaky test
    slot.start_hour = 8

    expect(slot.valid?).to be true

    slot.end_hour = 30

    expect(slot.valid?).to be false

    slot.end_hour = 12

    expect(slot.valid?).to be true

    slot.start_hour = 12

    # start must be greater than end
    expect(slot.valid?).to be false
  end

  it "should only accept days of the week" do
    slot.day_of_week = "FAKE"

    expect(slot.valid?).to be false
  end
end
