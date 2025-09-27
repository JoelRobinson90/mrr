# typed: true
# frozen_string_literal: true

module CronJob
  class Notification

    def initialize
      webhook = EnvHelper.env_or_nil("SLACK_CRON_NOTIFICATIONS_WEBHOOK")
      @notifier = Slack::Notifier.new(webhook) do
        defaults channel:  "#tech-dev",
                 username: "#{Rails.env}_cron_jobs"
      end
    end

    def slack(message)
      @notifier.ping message
      message
    end
  end
end
