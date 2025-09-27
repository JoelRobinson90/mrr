# typed: true
# frozen_string_literal: true

class AppointmentReminderCronJob < ApplicationJob
  include ScheduledCronJob

  # Every day at 5:00pm UTC => 12pm EST/1pm EDT
  self.cron_expression = "0 17 * * *"

  def perform
    AppointmentReminder.new.call
  end
end
