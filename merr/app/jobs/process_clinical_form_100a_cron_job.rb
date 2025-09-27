# typed: true
# frozen_string_literal: true

class ProcessClinicalForm100aCronJob < ApplicationJob
  include ScheduledCronJob

  # Every day at 01:30 UTC
  self.cron_expression = "30 1 * * *"

  def perform
    Alayacare::ProcessClinicalForm100a.new.process_s3_files
  end
end
