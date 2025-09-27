# typed: true
# frozen_string_literal: true

module Alayacare
  class PullVisitStatuses < ApiClient
    def initialize(start_date = Time.zone.now - 8.hours, end_date = Time.zone.now + 8.hours)
      super()
      @start_date = start_date
      @end_date = end_date
      @cancel_codes = {}
    end

    def call
      visits = Visit.where(start_time: @start_date..@end_date)

      unless visits.empty?
        count = 0
        ac_result = GetPaginatedIndex.call(@api,
                                           "scheduler/visits?start_date_from=#{@start_date}&start_date_to=#{@end_date}")
        unless ac_result.success?
          Rails.logger.info { "Polling visit statuses between #{@start_date} and #{@end_date} failed" }
          return
        end
        ac_visits = ac_result.payload

        if ac_visits&.select {|ac_visit| ac_visit["cancelled"] }.any?
          # hash with codes as the key and id as the value
          @cancel_codes = CancelCode.all.pluck(:code, :id).to_h
        end

        visits.each do |visit|
          matching_visit = ac_visits&.select {|ac_visit| ac_visit["visit_id"] == visit.external_id } || []

          next if matching_visit.empty?

          new_status = matching_visit[0]["status"]
          new_cancel_flag = matching_visit[0]["cancelled"]
          new_cancel_code = matching_visit.dig(0, "cancel_code", "code")
          new_cancel_code_id = @cancel_codes[new_cancel_code]

          next unless new_status != visit.alayacare_status ||
                      visit.canceled != new_cancel_flag ||
                      visit.cancel_code_id != new_cancel_code_id

          # If the status has changed, check if there is new clock-in or clock-out data.
          update_work_sessions(visit) if new_status != visit.alayacare_status

          visit.alayacare_status = new_status
          visit.canceled = new_cancel_flag

          if visit.canceled && new_cancel_code_id.blank?
            Rails.logger.info { "Polling can't find cancel code '#{new_cancel_code}' to update #{visit.external_id}" }
          else
            visit.cancel_code_id = new_cancel_code_id
          end

          visit.skip_push_to_external = true
          visit.save
          count += 1
        end
        Rails.logger.info { "Polling updated #{count} visit statuses between #{@start_date} and #{@end_date}" }
      end
    end

    def update_work_sessions(visit)
      # We don't get the work sessions from the index.  Need to call for full data.
      ac_visit_response = @api.get("scheduler/visits/by_id/#{visit.external_id}")

      if ac_visit_response.success?
        ac_visit = begin
          JSON.parse(ac_visit_response.body)
        rescue StandardError
          nil
        end

        UpdateWorkSessions.call(visit, ac_visit["work_sessions"]) if ac_visit["work_sessions"].present?
      end
    end
  end
end
