# frozen_string_literal: true

module Routing
  class CheckRaceCondition < ::ApplicationService
    include Helpers

    def initialize(visit)
      @visit = visit

      buffer = @visit&.program&.minutes_of_buffer_time&.minutes || 15.minutes
      buffer -= @visit&.program&.max_grace_period&.minutes || 0.minutes
      @safe_buffer = buffer - 1.minute
    end

    def call
      return OpenStruct.new(success?: true) if @visit.field_provider_id.blank?

      conflicts = Visit.where(field_provider_id: @visit.field_provider_id)
                       .where("start_time < ?", @visit.end_time + @safe_buffer)
                       .where("end_time > ?", @visit.start_time - @safe_buffer)
                       .where(canceled: false)
                       .pluck(:ma_id)

      return OpenStruct.new(success?: true) unless conflicts.present?

      fp = @visit.field_provider&.full_name
      buffer = "#{@safe_buffer / 60} minute buffer"
      time_range = "#{@visit.start_time} to #{@visit.end_time} (#{buffer})"
      visit_conflicts = "visit#{'s' if conflicts.length != 1} #{conflicts.to_sentence}"

      err = "Visit with #{fp} from #{time_range} conflicts with existing #{visit_conflicts}."
      return OpenStruct.new({success?: false, error: err})
    end
  end
end
