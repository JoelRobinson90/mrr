# frozen_string_literal: true

module Routing
  class AddRetroactiveDriveTime < ::ApplicationService
    include Helpers

    def initialize(ac_visits)
      @ac_visits = ac_visits

      # For fetching fp info
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
    end

    def call
      annotated_visits = []

      ac_visits = @ac_visits.sort_by {|visit| visit[:start_time] }

      all_fps = FieldProvider.includes(:address).where(external_id: ac_visits.map(&:fp_id)).uniq
      fp_hash = all_fps.map {|fp| [fp.external_id, {location: fp.lat_long, timezone: fp.address&.timezone}]}.to_h

      ac_visits.group_by(&:fp_id).each do |fp_id, fp_visits|
        next if fp_id.blank?
        fp_location = fp_hash.dig(fp_id, :location)
        fp_location = get_fp_location(fp_id) if fp_location.blank?

        # Group visits by date in local time.
        fp_visits.group_by do |visit|
          timezone = fp_hash.dig(fp_id, :timezone) || get_fp_timezone(fp_id) || "America/Los_Angeles"
          visit[:start_time].in_time_zone(timezone).to_date
        end.each do |_date, visit_group|
          next if visit_group.blank?

          locations = fp_location.nil? ? visit_group.pluck(:location) : [fp_location].concat(visit_group.pluck(:location))
          drive_times_and_distances = get_drive_times_and_distances_list(locations)

          if drive_times_and_distances.blank?
            # still return visits even if we can't find drive times
            annotated_visits.concat(visit_group)
          else
            if fp_location.nil?
              drive_times_and_distances[:drive_times].unshift(nil)
              drive_times_and_distances[:drive_distances].unshift(nil)
            end

            visit_group.each_with_index do |visit, i|
              visit.drive_time = drive_times_and_distances[:drive_times][i]
              visit.drive_distance = drive_times_and_distances[:drive_distances][i]

              annotated_visits << visit
            end
          end
        end
      end

      OpenStruct.new(success?: true, payload: annotated_visits)
    end
  end
end
