# frozen_string_literal: true

module Routing
  module Helpers
    def profile(title)
      t = Time.now
      result = yield
      run_id = @run_id.present? ? " (run_id: #{@run_id})" : ""
      p "#{sprintf('%.3f', Time.now - t)} seconds to #{title}#{run_id}"
      result
    end

    def log_message(msg, level: :info)
      msg = "#{@run_id} #{msg}"
      level == :info ? Rails.logger.info(msg) : Rails.logger.error(msg)
      # To actually show up in data dog "Rails.logger.info" doesn't work.
      p msg
    end

    def get_fp_name(id)
      return nil if id.blank?

      result = Rails.cache.fetch("ac_field_provider_name_#{id}", expires_in: 1.day) do
        @api.get("employees/employees/by_id/#{id}")
      end

      return nil unless result.success?

      body = JSON.parse(result.body)

      first_name = body.dig("demographics", "first_name")
      last_name = body.dig("demographics", "last_name")

      "#{first_name} #{last_name}".strip
    end

    def get_fp_location(id)
      # Check for local
      local_fp = FieldProvider.includes(:address).find_by(external_id: id)
      if local_fp.present? && local_fp.address.present?
        addr = local_fp.address
        return "#{addr.latitude},#{addr.longitude}" if addr.present? && addr.latitude.present?
      end

      # Load from AC if not found
      result = Rails.cache.fetch("ac_field_provider_loc_#{id}", expires_in: 1.day) do
        @api.get("employees/employees/by_id/#{id}")
      end

      return nil unless result.success?

      body = JSON.parse(result.body)

      location = body.dig("demographics", "location")
      return nil if location.blank?

      "#{location['lat']},#{location['lon']}"
    end

    def get_fp_timezone(id)
      result = Rails.cache.fetch("ac_field_provider_loc_#{id}", expires_in: 1.day) do
        @api.get("employees/employees/by_id/#{id}")
      end

      return nil unless result.success?

      JSON.parse(result.body)["timezone"]
    end

    def is_blocking(range1, range2)
      # check for any overlap, even partial
      range1[:fp_id] == range2[:fp_id] &&
        range1[:start_time] < range2[:end_time] &&
        range1[:end_time] > range2[:start_time]
    end

    def round_time_15(datetime)
      minutes = 15
      offset = datetime.min % minutes

      if offset > minutes / 2
        datetime + (minutes - offset).minutes
      else
        datetime - offset.minutes
      end
    end

    def get_drive_times_and_distances_list(locations)
      return nil if locations.compact.length < 2

      origin = locations[0]
      destination = locations[-1]

      waypoints = CGI.escape(locations[1...-1].join("|"))
      token = "AIzaSyBepKqwdkNKFWWydPgtaxSJNUlpAR4h3fM"

      @api_base = "https://maps.googleapis.com/maps/api/directions/json"

      query = "?destination=#{destination}&origin=#{origin}&waypoints=#{waypoints}&key=#{token}"

      body = Rails.cache.fetch("visit_drive_times_#{locations.join('|').gsub(',', '_')}", expires_in: 1.day) do
        response = RestClient.get(@api_base + query)

        return nil if response&.code != 200

        JSON.parse(response.body)
      end

      return nil if body.blank?

      drive_times = body.dig("routes", 0, "legs").map do |leg|
        leg["duration"]["value"]
      end.map {|duration_in_seconds| duration_in_seconds / 60 } # to minutes

      drive_distances = body.dig("routes", 0, "legs").map do |leg|
        leg["distance"]["value"]
      end.map {|distance_in_meters| distance_in_meters / 1609.34 } # to miles

      {drive_times: drive_times, drive_distances: drive_distances}
    end

    # converts any range to 0-100.
    def normalized_value(value, max:, min: 0)
      base = value - min
      range = max - min

      # Avoid zero division error
      return value < max ? 0 : 100 if range <= 0

      # Truncate base to be between 0 and range so result will be between 0 and 100.
      base = [base, range].min
      base = [base, 0].max

      (base / range.to_f) * 100
    end

    def exponential_normalized_value(value, max:, min: 0)
      base = value - min
      range = max - min

      # Avoid zero division error
      return value < max ? 0 : 100 if range <= 0

      return 0 if value < min
      return 100 if value > max

      (base**2) / (range.to_f**2) * 100
    end

    def instantiate_visit(visit:, location: nil, demand_partner: nil, patient: nil, fp_name: nil, include_local_visit: true)
      alayacare_api_visit = AlayacareApiVisit.new(
        id:                 visit["visit_id"] || visit["alayacare_visit_id"],
        alayacare_visit_id: visit["alayacare_visit_id"],
        visit_id:           visit["visit_id"],
        fp_id:              visit["employee_id"],
        fp_name:            fp_name,
        start_time:         Time.zone.parse(visit["start_at"]),
        end_time:           Time.zone.parse(visit["end_at"]),
        cx_start:           round_time_15(Time.zone.parse(visit["start_at"])),
        cx_end:             round_time_15(Time.zone.parse(visit["end_at"])),
        demand_partner_id:  patient&.demand_partner_id, # this is needed for graphql queries
        demand_partner:     demand_partner,
        patient:            patient,
        status:             visit["status"],
        client_id:          visit["client_id"],
        notes:              visit["notes"]&.sort do |x, y|
                              Time.zone.parse(y["created_at"]) <=> Time.zone.parse(x["created_at"])
                            end,
        cancelled:          visit["cancelled"],
        location:           location,
        cancel_code:        visit["cancel_code"]
      )

      if include_local_visit
        ma_visit = Visit.find_by external_id: alayacare_api_visit[:visit_id]
        alayacare_api_visit.local                = ma_visit.present?
        alayacare_api_visit.ma_visit             = ma_visit&.to_builder&.attributes!
        alayacare_api_visit.visit_type           = ma_visit.visit_type.to_builder.attributes! if ma_visit&.visit_type
        alayacare_api_visit.services             = ma_visit.services.map {|s| s.to_builder.attributes! } if ma_visit
        alayacare_api_visit.service_instructions = ma_visit.service_instructions if ma_visit
        if alayacare_api_visit.patient
          alayacare_api_visit.patient = alayacare_api_visit.patient.to_builder(include_programs: true).attributes!
        end
      end

      alayacare_api_visit
    end
  end
end
