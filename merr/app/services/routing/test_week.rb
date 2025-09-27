# frozen_string_literal: true

module Routing
  class TestWeek < ::ApplicationService
    attr_accessor :endpoint

    def initialize(start_date, end_date, appt_duration = 90, _existing_appt_data = nil)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)

      @appt_duration = appt_duration
      @start_date = start_date
      @end_date = end_date
      @existing_appt_data = existing_appointment_data

      @start_date_str = CGI.escape(@start_date.iso8601)
      @end_date_str = CGI.escape(@end_date.iso8601)

      # format: hash with keys start_time, created_time, fp_name, employee_loc, client_loc, client_address
      @existing_appt_data = existing_appointment_data
    end

    def call
      Rails.logger.debug "Create new service and call methods as needed."
    end

    def process_existing_appointments
      @existing_appt_data = @existing_appt_data.map do |appt|
        appt[:start_time] = Time.zone.parse(appt[:start_time])
        appt[:created_time] = Time.zone.parse(appt[:created_time])
        appt[:patient] = Address.find_by(address_line_one: appt[:client_address]).addressable
        # make sure it's geocoded
        appt[:patient].address.save
        appt
      end
    end

    def clear_existing
      raise "PROD DANGER" unless ENV["ALAYACARE_ENVIRONMENT"] == "uat"

      result = @api.get("scheduler/visits?start_at=#{@start_date_str}&end_at=#{@end_date_str}")

      raise result.body unless result.success?

      body = JSON.parse(result.body)

      body["items"].each do |visit|
        Rails.logger.debug "scheduler/visits/#{visit['alayacare_visit_id']}"

        # p @api.delete("scheduler/visits/#{visit['alayacare_visit_id']}")
      end
    end

    def make_appointments
      raise "PROD DANGER" unless ENV["ALAYACARE_ENVIRONMENT"] == "uat"

      @existing_appt_data.each do |appt|
        result = Routing::VisitOptimizerWrapper.call(appt[:patient], @start_date, @end_date, @appt_duration)

        raise result.error unless result.success?

        options = result.payload

        Rails.logger.debug { "OPTIONS COUNT: #{options.length}" }

        if options.empty?
          Rails.logger.debug { "NO OPTIONS: #{appt}" }
        else
          picked = options.first
          result = Alayacare::ClientCreateVisit.call(appt[:patient], picked[:appt_start], picked[:appt_end], 6,
                                                     picked[:fp_id])
          if result.success?
            Rails.logger.debug { "Created appt: #{picked[:fp_id]} #{picked[:appt_start]}" }
          else
            Rails.logger.debug { "ERROR: #{result.error} #{result.body} #{appt} #{picked}" }
          end
        end
      end
    end

    def get_fp_location(id)
      result = Rails.cache.fetch("ac_field_provider_loc_#{id}", expires_in: 1.day) do
        @api.get("employees/employees/by_id/#{id}")
      end

      return nil unless result.success?

      body = JSON.parse(result.body)

      location = body.dig("demographics", "location")
      return nil if location.blank?

      "#{location['lat']},#{location['lon']}"
    end

    def get_drive_time_list(locations)
      return 0 if locations.length < 2

      origin = locations[0]
      destination = locations[1]

      waypoints = CGI.escape(locations[1...-1].join("|"))
      token = "AIzaSyBepKqwdkNKFWWydPgtaxSJNUlpAR4h3fM"

      @api_base = "https://maps.googleapis.com/maps/api/directions/json"

      query = "?destination=#{destination}&origin=#{origin}&waypoints=#{waypoints}&key=#{token}"

      begin
        result = RestClient.get(@api_base + query)
      rescue StandardError => e
        return nil
      end

      return nil if result.code != 200

      # TODO: better error handling here

      body = JSON.parse(result.body)

      body.dig("routes", 0, "legs").map {|leg| leg["duration"]["value"] }.reduce(&:+) / 60
    end

    def analyze_results
      appts = Routing::GetAppointments.call(@start_date, @end_date).payload

      fp_appts = {}

      appts.each do |appt|
        fp_id = appt[:fp_id]
        if fp_appts[fp_id].blank?
          fp_appts[fp_id] = [appt]
        else
          fp_appts[fp_id] << appt
        end
      end

      # sort each field providers list of appointments
      fp_appts.transform_values {|appts| appts.sort_by {|appt| appt[:start_time] } }

      total_routes = 0
      total_average_drive_time = 0

      fp_appts.each do |fp_id, appts|
        fp_location = get_fp_location(fp_id)
        Rails.logger.debug "-------------------------------------------------------"
        Rails.logger.debug { "Povider: #{fp_id}" }
        Rails.logger.debug "-------------------------------------------------------"
        appts.group_by {|item| item[:start_time].to_date }.each do |date, appt_group|
          locations = [fp_location].concat(appt_group.pluck(:location))
          locations << fp_location
          drive_time = get_drive_time_list(locations)
          next if drive_time.blank?

          average_drive = (drive_time / (locations.length - 1)).to_i

          total_routes += 1
          total_average_drive_time += average_drive

          Rails.logger.debug date
          Rails.logger.debug { "Drive time: #{drive_time} minutes" }
          Rails.logger.debug { "Average drive: #{average_drive} minutes" }
          Rails.logger.debug { "Visits: #{appt_group.length}" }
          Rails.logger.debug { "https://www.google.com/maps/dir/#{locations.join('/')}" }
          Rails.logger.debug ""
        end
        "done"
      end

      Rails.logger.debug "-------------------------------------------------------"
      Rails.logger.debug "Totals:"
      Rails.logger.debug "-------------------------------------------------------"
      Rails.logger.debug { "Visits: #{appts.length}" }
      Rails.logger.debug { "Routes: #{total_routes}" }
      Rails.logger.debug { "Average drive: #{(total_average_drive_time / total_routes).to_i}" }
      "done"
    end
  end
end
