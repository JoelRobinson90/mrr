# typed: true
# frozen_string_literal: true

module Alayacare
  class UpdateWorkSessions < ::ApplicationService
    def initialize(visit, ac_work_sessions)
      @visit = visit
      @ac_work_sessions = ac_work_sessions
    end

    def call
      updated = 0
      found = 0
      created = 0

      begin
        @ac_work_sessions.each do |ac_work_session|
          existing = nil
          clock_in = Time.zone.parse(ac_work_session["clock_in"])
          clock_out = (Time.zone.parse(ac_work_session["clock_out"]) if ac_work_session["clock_out"].present?)

          @visit.work_sessions.each do |ma_work_session|
            if ma_work_session.clock_in == clock_in
              existing = ma_work_session
              break
            end
          end

          if existing
            existing.clock_out = clock_out
            existing.clock_out_location = parse_ac_location(ac_work_session["clock_out_location"])
            if existing.changed?
              existing.save
              updated += 1
            else
              found += 1
            end
          else
            created += 1
            WorkSession.create(clock_in:           clock_in,
                               clock_out:          clock_out,
                               clock_in_location:  parse_ac_location(ac_work_session["clock_in_location"]),
                               clock_out_location: parse_ac_location(ac_work_session["clock_out_location"]),
                               field_provider:     @visit.field_provider,
                               visit:              @visit)
          end
        end

        msg = "Synced work sessions. Updated: #{updated} Found: #{found} Created: #{created}"
        Rails.logger.info msg
        OpenStruct.new(success?: true, message: msg)
      rescue StandardError => e
        Sentry.capture_exception(e)
        Rails.logger.info { "Failed work session sync: #{e.message}" }
        OpenStruct.new(success?: false, error: e.message)
      end
    end

    def parse_ac_location(ac_location)
      return nil if ac_location.blank?

      "#{ac_location['lat']},#{ac_location['lng']}"
    end
  end
end
