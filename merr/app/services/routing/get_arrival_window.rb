# frozen_string_literal: true

module Routing
  class GetArrivalWindow < ::ApplicationService
    include Helpers

    DEFAULT_OFFSET_IN_MINUTES = 30
    
    def initialize(start_time, patient_timezone, block_schedule, offset, existing_window)
      @start_time = start_time
      @timezone = patient_timezone
      @block_schedule = block_schedule
      @offset = offset
      @existing_window = existing_window
    end

    def call
      rounded_start_time = round_time_15(@start_time)

      arrival_range = get_arrival_window(rounded_start_time, @timezone, @block_schedule, @offset, @existing_window)

      return OpenStruct.new(success?: false) if arrival_range.blank?

      OpenStruct.new(success?: true, payload: arrival_range)
    end

    # Expected format for arrival_window_block_schedule: 10-14,16-18,18-20
    def get_arrival_window(start_time, timezone, block_schedule, offset, existing_window)

      # Don't re-calculate if new start time is still in window.
      if existing_window.respond_to?(:length) && existing_window.length == 2 && existing_window.all?
        return existing_window if (existing_window[0]..existing_window[1]).cover? start_time
      end

      return default_arrival_window(start_time) if timezone.blank?

      begin
        local_time = start_time.in_time_zone(timezone)
      rescue ArgumentError
        # Give up if timezone not recognized
        return offset_or_default(start_time, offset)
      end

      # Strip out any whitespace and then seperate the blocks into a list
      blocks = block_schedule&.gsub(/\s+/, "")&.split(",") || []

      blocks.each do |block|
        block_start_hour, block_end_hour = block.split("-").map(&:to_i)
        block_start = local_time.change(hour: block_start_hour)
        block_end = local_time.change(hour: block_end_hour)

        return [block_start.utc, block_end.utc] if (block_start..block_end).cover? local_time
      end

      # Use offset if no blocks match
      return offset_or_default(start_time, offset)
    end

    def offset_or_default(start_time, offset)
      return [(start_time - offset.minutes).utc, (start_time + offset.minutes).utc] if offset.present?

      default_arrival_window(start_time)
    end

    def default_arrival_window(start_time)
      [start_time - DEFAULT_OFFSET_IN_MINUTES.minutes, start_time + DEFAULT_OFFSET_IN_MINUTES.minutes]
    end
  end
end
