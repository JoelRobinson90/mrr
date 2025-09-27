# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlexibleShift, type: :model do
  describe "flexible_shift" do
    describe "invalid range should fail initializer" do
      let(:shift_start) { DateTime.new(2022, 8, 25, 8, 0) }
      let(:shift_end) { shift_start - 8.hours }
      let(:work_start) { DateTime.new(2022, 8, 25, 8, 0) }
      let(:work_end) { work_start + 8.hours }
      it "raises an exception" do
        expect { FlexibleShift.new([shift_start, shift_end], [work_start, work_end], 8 * 60) }.to raise_exception
      end
    end

    describe "can calculate shift time" do
      let(:shift_start) { DateTime.new(2022, 8, 25, 8, 0) }
      let(:shift_end) { shift_start + 10.hours }
      let(:work_start) { DateTime.new(2022, 8, 25, 8, 0) }
      let(:work_end) { work_start + 8.hours }
      let(:flexible_shift) { FlexibleShift.new([shift_start, shift_end], [work_start, work_end], 8 * 60) }
      it "calculates shift time" do
        expect(flexible_shift.shift_time).to eq(10 * 60)
      end
      it "calculates work time" do
        expect(flexible_shift.work_time).to eq(8.0 * 60)
      end
    end

    describe "can shorten a long shift" do
      let(:shift_start) { DateTime.new(2022, 8, 25, 8, 0) }
      let(:shift_end) { shift_start + 10.hours }
      let(:work_start) { DateTime.new(2022, 8, 25, 8, 0) }
      let(:work_end) { work_start + 8.hours }
      let(:flexible_shift) { FlexibleShift.new([shift_start, shift_end], [work_start, work_end], 8 * 60) }
      it "can shorten the shift" do
        expect(flexible_shift.can_shorten).to eq(true)
      end
      it "calculates shorten length correctly" do
        expect(flexible_shift.shorten_amount).to eq(2 * 60)
      end
    end

    describe "can shorten a short shift" do
      let(:shift_start) { DateTime.new(2022, 8, 25, 8, 0) }
      let(:shift_end) { shift_start + 9.hours }
      let(:work_start) { DateTime.new(2022, 8, 25, 8, 0) }
      let(:work_end) { work_start + 4.hours }
      let(:flexible_shift) { FlexibleShift.new([shift_start, shift_end], [work_start, work_end], 8 * 60) }
      it "can shorten the shift" do
        expect(flexible_shift.can_shorten).to eq(true)
      end
      it "calculates shorten length correctly" do
        expect(flexible_shift.shorten_amount).to eq(60)
      end
    end
  end
end
