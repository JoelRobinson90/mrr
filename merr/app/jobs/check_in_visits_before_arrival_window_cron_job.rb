# typed: true
# frozen_string_literal: true

class CheckInVisitsBeforeArrivalWindowCronJob < ApplicationJob
  include ScheduledCronJob

  # Every five minutes
  self.cron_expression = "*/5 * * * *"

  def perform
    target = Time.now + 10.minutes

    # Visits that are about to hit the arrival window
    visits = Visit.where("arrival_window_start < ? AND arrival_window_end > ?", target, target)
    # That haven't been checked in already
    visits = visits.where(athena_encounter_id: nil)
    # That aren't canceled
    visits = visits.where(canceled: false)

    # Get the count before updating the visits
    visits_to_update = visits.count
    
    visits.each do |visit|
      Athena::InitiateVisitCheckIn.call(visit)
    end

    p "Checked-in #{visits_to_update} visits." if visits_to_update.positive?
  end
end
