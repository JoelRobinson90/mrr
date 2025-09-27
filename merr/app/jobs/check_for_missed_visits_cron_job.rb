# typed: true
# frozen_string_literal: true

class CheckForMissedVisitsCronJob < ApplicationJob
  include ScheduledCronJob

  # Every five minutes
  self.cron_expression = "*/5 * * * *"

  def perform
    Visit.where("start_time < ?", Time.zone.now - 5.minutes)
         .where(status: "scheduled")
         .each do |visit|
      visit.update(status: "late")
    end

    Visit.where("start_time < ?", Time.zone.now - 20.minutes)
         .where(status: "late")
         .each do |visit|
      visit.update(status: "missed")
    end
  end
end
