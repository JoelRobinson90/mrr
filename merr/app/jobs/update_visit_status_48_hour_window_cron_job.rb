# typed: true
# frozen_string_literal: true

class UpdateVisitStatus48HourWindowCronJob < ApplicationJob
  include ScheduledCronJob

  # Every hour
  self.cron_expression = "0 * * * *"

  def perform
    Alayacare::PullVisitStatuses.call(Time.zone.now - 5.days, Time.zone.now + 5.days)
  end
end
