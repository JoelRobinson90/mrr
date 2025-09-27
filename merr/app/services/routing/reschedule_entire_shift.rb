# frozen_string_literal: true

module Routing
  class RescheduleEntireShift < ::ApplicationService
    include Helpers

    def initialize(datestr, old_field_provider, new_field_provider)
      @timezone = old_field_provider.address.timezone
      target_date = datestr.in_time_zone(@timezone)
      @start_time = target_date.beginning_of_day
      @end_time = target_date.end_of_day
      @old_fp = old_field_provider
      @new_fp = new_field_provider
    end

    def call
      visits_to_reschedule = Visit.where(field_provider_id: @old_fp.id)
                                  .where("start_time >= ? AND end_time <= ?", @start_time, @end_time)
      possible_conflicts = Visit.where(field_provider_id: @new_fp.id)
                                .where("start_time >= ? AND end_time <= ?", @start_time, @end_time)

      visits_to_reschedule.each do |visit|
        possible_conflicts.each do |existing_visit|
          if is_blocking(visit, existing_visit)
            msg = "Visit from #{time_range(visit)} is blocked by visit from #{time_range(existing_visit)}"
            return OpenStruct.new(success?: false, error: msg)
          end
        end
      end

      visits_to_reschedule.each do |visit|
        unless visit.update(field_provider: @new_fp)
          return OpenStruct.new(success?: false, error: visit.errors.full_messages.to_sentence)
        end
      end

      OpenStruct.new(success?: true, message: "Rescheduled #{visits_to_reschedule.length} visits")
    end

    private

    def time_range(visit)
      "#{format_time(visit.start_time)} to #{format_time(visit.end_time)}"
    end

    def format_time(time)
      time.in_time_zone(@timezone).strftime("%l:%M%P")
    end
  end
end
