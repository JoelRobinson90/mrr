# frozen_string_literal: true

class FlexibleShift
  include ActiveModel::Model

  def initialize(shift_range, work_range, min_shift_length = None, shorten_limit = 30.0)
    @shift_range = shift_range
    @work_range = work_range
    @min_shift_length = min_shift_length # in minutes
    @shorten_limit = shorten_limit # in minutes; never shorten less than this amount

    # Both work range and shift range should be start to end
    if @shift_range[0] >= @shift_range[1] || @work_range[0] >= @work_range[1]
      raise StandardError, "Shift range or work range is non-zero or negative."
    end
    # Work range should be entirely within shift range.
    if @shift_range[0] > @work_range[0] || @shift_range[1] < @work_range[1]
      raise StandardError, "Work range is not entirely contained by shift range."
    end
  end

  # Shift time in minutes
  def shift_time
    (@shift_range[1].to_time - @shift_range[0].to_time) / 1.hour.in_minutes
  end

  # work time in minutes
  def work_time
    (@work_range[1].to_time - @work_range[0].to_time) / 1.hour.in_minutes
  end

  def can_shorten
    return false unless @min_shift_length
    return false if shift_time <= @min_shift_length

    return true if shift_time - work_time >= @shorten_limit

    false
  end

  def shorten_amount
    if can_shorten
      shift_time - [@min_shift_length, work_time].max
    else
      0
    end
  end
end
