# frozen_string_literal: true

module Routing
  class SlotScorer < ::ApplicationService
    include Helpers

    def initialize(option, shift, visits, weights, earliest_time, latest_time, buffer_time, min_shift_length, drive_time_breakpoints)
      @option = option
      @shift = shift
      @visits = visits || []
      @weights = weights
      @earliest_time = earliest_time
      @latest_time = latest_time
      @buffer_time = buffer_time
      @min_shift_length = min_shift_length || 0
      @drive_time_breakpoints = drive_time_breakpoints

      @non_contiguous_penalty = 20
      @components = %w[drive proximity utilization shift_shortening_penalty]
    end

    def call
      required_params = [@option, @shift, @weights, @earliest_time, @latest_time, @buffer_time]
      unless required_params.all?
        payload = {
          total_score:                    0,
          drive_score:                    0,
          proximity_score:                0,
          utilization_score:              0,
          shift_shortening_penalty_score: 0
        }
        err = "Param missing - #{required_params}"
        return OpenStruct.new(success?: false, error: err, payload: payload)
      end

      score = {
        drive_score:                    get_drive_score,
        proximity_score:                get_proximity_score,
        utilization_score:              get_utilization_score,
        shift_shortening_penalty_score: get_shift_shortening_score
      }

      calculate_total_score(score, @weights)

      round_answers(score)

      OpenStruct.new(success?: true, payload: score)
    end

    def get_drive_score
      # Parse JSON if passed in as string.
      if @drive_time_breakpoints.is_a? String
        @drive_time_breakpoints = JSON.parse(@drive_time_breakpoints)
      end

      # The lower the drive time, the higher the drive_score.
      # Drive times above 2 hours all score 0.
      score = interpolate_drive_time_breakpoints(@option[:expected_drive], @drive_time_breakpoints, 0, 120)

      # Subtract penalty if option is non-contiguous, minimum score of 0.
      score = [0, score - @non_contiguous_penalty].max unless @option[:contiguous]
      score
    end

    def get_proximity_score
      # The closer in time the option is to the earliest possible, the higher the score.
      100 - exponential_normalized_value(@option[:appt_start], min: @earliest_time,
                                                               max: [(@earliest_time + 15.days).end_of_day, @latest_time].min)
    end

    def get_utilization_score
      calculate_shift_utilization

      # The more unutilized the shift is, the higher the score.
      100 - normalized_value(@shift[:utilization], max: 1)
    end

    def get_shift_shortening_score
      calculate_shift_shortening_penalty

      # The more a shift is not at the beginning or end of a shortenable
      # shift, the higher the score. The maximum value is the total that a
      # shift could be shortened in minutes.
      100 - normalized_value(@shift[:shift_shortening_penalty], max: 3.hours.in_minutes)
    end

    # Final score is calculated from all sub-scores with a weighted average.
    def calculate_total_score(score, weights)
      total = 0
      @components.each do |component|
        total += score["#{component}_score".to_sym] * (weights["#{component}_weight".to_sym] / 100.0)
      end

      score[:total_score] = total
    end

    def round_answers(score)
      score[:precise_score] = score[:total_score]

      [@components, :total].flatten.each do |component|
        score["#{component}_score".to_sym] = score["#{component}_score".to_sym].round
      end
    end

    def calculate_shift_utilization
      return if @shift[:utilization].present?

      blocks = get_shift_blocks

      @shift[:utilization] = 0 and return if blocks.blank?

      total_time = @shift[:end_time] - @shift[:start_time]

      visit_times = blocks.map do |block|
        start_time = [block[:start_time], @shift[:start_time]].max
        end_time = [block[:end_time], @shift[:end_time]].min

        end_time - start_time
      end

      # Each blocker has two buffers, but there is no buffer to start or end shift, so subtract 2.
      buffer_count = [0, (blocks.length * 2) - 2].max
      total_buffer_time = @buffer_time * buffer_count * 60

      @shift[:utilization] = (visit_times.sum + total_buffer_time) / total_time
    end

    def calculate_shift_shortening_penalty
      return if @shift[:shift_shortening_penalty].present?

      if @weights[:shift_shortening_penalty_weight] == 0
        @shift[:shift_shortening_penalty] = 0
        return
      end

      # A penalty if the shift is at the beginning or ending of a shift that can be shortened,
      # zero otherwise
      total_time = @shift[:end_time] - @shift[:start_time]
      if @min_shift_length.blank? || @min_shift_length.zero? || (total_time <= @min_shift_length)
        @shift[:shift_shortening_penalty] = 0
        return
      end

      blocks = get_shift_blocks

      @shift[:shift_shortening_penalty] = 0 and return if blocks.blank?

      work_start = blocks.pluck(:start_time).min
      work_end = blocks.pluck(:end_time).max

      shift_before_changes = FlexibleShift.new([@shift[:start_time], @shift[:end_time]],
                                               [work_start, work_end], @min_shift_length * 60)
      new_work_start = [work_start, @option[:appt_start]].min
      new_work_end = [work_end, @option[:appt_end]].max
      shift_after_changes = FlexibleShift.new([@shift[:start_time], @shift[:end_time]],
                                              [new_work_start, new_work_end], @min_shift_length * 60)

      @shift[:shift_shortening_penalty] = shift_before_changes.shorten_amount - shift_after_changes.shorten_amount
    end

    def get_shift_blocks
      @visits.select {|appt| is_blocking(appt, @shift) }
    end

    def interpolate_drive_time_breakpoints(drive_time, breakpoints, best_value, worst_value)
      breakpoints = (breakpoints || []).map(&:symbolize_keys)
      breakpoints << {drive: best_value, score: 100}
      breakpoints << {drive: worst_value, score: 0}

      breakpoints = breakpoints.sort_by { |breakpoint| breakpoint[:drive] }

      if drive_time <= breakpoints[0][:drive]
        return breakpoints[0][:score]
      end

      if drive_time >= breakpoints[-1][:drive]
        return breakpoints[-1][:score]
      end

      breakpoints.each_with_index do |breakpoint, i|
        next_breakpoint = breakpoints[i + 1]

        if drive_time >= breakpoint[:drive] && drive_time <= next_breakpoint[:drive]
          # This is always safe because we know drive_time is less than the last breakpoint.
          remainder = drive_time - breakpoint[:drive]
          range = next_breakpoint[:drive] - breakpoint[:drive]
          ratio = remainder / range.to_f
          score_range = breakpoint[:score] - next_breakpoint[:score]
          result = breakpoint[:score] - (score_range * ratio)
          result = [result,0].max
          result = [result,100].min
          return result
        end
      end

      # should never get here
      return 0
    end

  end
end
