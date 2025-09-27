# typed: true
# frozen_string_literal: true

class UpdateVisitStatus4HourWindowCronJob < ApplicationJob
  include ScheduledCronJob

  # Every five minutes
  self.cron_expression = "*/5 * * * *"

  def perform
    Alayacare::PullVisitStatuses.call
  end
end
