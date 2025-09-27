# typed: true
# frozen_string_literal: true

class UpdateVisitStatus4WeekWindowCronJob < ApplicationJob
  include ScheduledCronJob

  # Every night at midnight
  self.cron_expression = "0 0 * * *"

  def perform
    Alayacare::PullVisitStatuses.call(Time.zone.now - 21.days, Time.zone.now + 21.days)
  end
end
