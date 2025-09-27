# frozen_string_literal: true

require "haversine"

module Routing
  class GetShifts < ::ApplicationService
    include Helpers
    attr_accessor :endpoint

    def initialize(start_date, end_date, anchor_location: nil, max_distance: nil,
                   run_id: nil, include_users: false, assigned_fp_ids: nil,
                   resource_requirements: nil)
      @alayacare_api = Authentication::Api.new(Authentication::AlayacareBroker)
      @wiw_api = Authentication::Api.new(Authentication::WhenIWorkBroker)

      @start_date = CGI.escape(start_date.beginning_of_day.iso8601)
      @end_date = CGI.escape(end_date.end_of_day.iso8601)
      @shifts = []
      @max_distance = max_distance
      @anchor_location = anchor_location
      @run_id = run_id
      @include_users = include_users
      @assigned_fp_ids = assigned_fp_ids
      @virtual_provider_roles = get_virtual_provider_roles(resource_requirements)
    end

    def call
      @shifts = []

      result = get_shifts_from_when_i_work

      return OpenStruct.new(success?: false, error: result.body) unless result.success?

      profile("add_fp_location_and_groups") { add_fp_location_and_groups }

      # shifts without a location can mess up scheduling
      filter_out_no_location_shifts
      filter_out_distant_shifts

      # If we want to use the shifts for a particular FP, filter to those shifts alone.
      # Otherwise, if we want to include all users, grab the ones we don't have
      has_assigned_fp_ids = @assigned_fp_ids&.length

      profile("include_all_users") { include_all_users if @include_users }

      filter_to_patient_assigned_fps if has_assigned_fp_ids

      OpenStruct.new(success?: true, payload: @shifts)
    end

    def get_shifts_from_when_i_work
      result = @wiw_api.get("shifts?start=#{@start_date}&end=#{@end_date}")
      return result unless result.success?

      body = JSON.parse(result.body)

      # Employee data is de-normalized in results
      provider_hash = body["users"]&.map {|user| [user["id"], user["employee_code"]] }.to_h

      location_hash = get_body_hash(body, "locations")
      site_hash = get_body_hash(body, "sites")
      location_name_hash = body["locations"]&.map {|loc| [loc["id"], loc["name"]] }.to_h

      @shifts = body["shifts"].map do |shift|
        new_shift = parse_shift(shift, provider_hash)
        new_shift[:location_name] = location_name_hash[shift["location_id"]]

        if site_hash.key?(shift["site_id"])
          new_shift[:location] = site_hash[shift["site_id"]]
        elsif location_hash.key?(shift["location_id"])
          new_shift[:location] = location_hash[shift["location_id"]]
        end
        new_shift
      end

      # Don't include shifts with no id
      @shifts = @shifts.select {|shift| shift[:fp_id].present? }

      OpenStruct.new(success?: true)
    end

    def parse_shift(shift, provider_hash)
      {
        fp_id:      provider_hash[shift["user_id"]],
        start_time: Time.zone.parse(shift["start_time"]),
        end_time:   Time.zone.parse(shift["end_time"])
      }
    end

    def get_body_hash(body, body_key)
      body_hash = {}
      if body.key?(body_key)
        body_hash = body[body_key]&.filter do |loc|
          loc["latitude"] != 0
        end.map do |loc|
          [loc["id"], format("%f,%f", loc["latitude"], loc["longitude"])]
        end.to_h
      end
      body_hash
    end

    def filter_out_distant_shifts
      return if @max_distance.blank? || @anchor_location.blank?

      @shifts.select! do |shift|
        return true if is_virtual_shift(shift)

        loc1 = convert_location_to_numbers(@anchor_location)
        loc2 = convert_location_to_numbers(shift[:location])
        distance = Haversine.distance(loc1, loc2).to_miles
        distance_acceptable = distance <= @max_distance
        unless distance_acceptable
          log_message("#{shift[:fp_name]}'s #{shift[:start_time]} shift at #{shift[:location]} blocked for being #{distance&.to_i} miles from #{@anchor_location}")
        end
        distance_acceptable
      end
    end

    def filter_out_no_location_shifts
      @shifts.select! do |shift|
        return true if is_virtual_shift(shift)

        # FIXME: hack to include all shifts virtual or not for the calendar view
        return true if @include_users

        has_location = shift[:location].present?
        unless has_location
          log_message("#{shift[:fp_name] || 'Unclaimed'}'s (#{shift[:fp_id]}) #{shift[:start_time]} shift blocked for no location")
        end
        has_location
      end
    end

    def is_virtual_shift(shift)
      @virtual_provider_roles.include? shift[:provider_role]
    end

    def filter_to_patient_assigned_fps
      @shifts.select! {|shift| @assigned_fp_ids.include?(shift[:fp_id]) }
    end

    def convert_location_to_numbers(location)
      return location if location.instance_of?(Array)

      location.split(",").map(&:strip).map(&:to_f)
    end

    def add_fp_location_and_groups
      local_fp_hash = get_field_provider_hash(@shifts.pluck(:fp_id).uniq)
      @shifts.each do |shift|
        id = shift[:fp_id]
        local_field_provider = local_fp_hash[id]
        shift[:provider_role] = local_field_provider&.role

        if local_field_provider&.visits
          field_provider_ids = local_field_provider&.visits.joins(:visit_resources).select("*").pluck("visit_resources.field_provider_id").uniq
          shift[:providers] = field_provider_ids.map {|id| FieldProvider.find id }
        end

        shift[:fp_name] = local_field_provider.full_name if local_field_provider.present?

        if local_field_provider&.address&.latitude.present?
          shift[:groups] = local_field_provider.visits.map {|v| v.patient.demand_partner.name }.uniq
          # Location may be overridden by assigning a site to a shift
          unless shift.key?(:location)
            shift[:location] = "#{local_field_provider.address.latitude},#{local_field_provider.address.longitude}"
          end
        else
          # otherwise fallback to AC
          assign_fp_location_from_alayacare(fp_id: id, shift: shift)
        end
      end
    end

    def assign_fp_location_from_alayacare(fp_id:, shift:)
      result = Rails.cache.fetch("ac_field_provider_loc_#{fp_id}", expires_in: 1.day) do
        @alayacare_api.get("employees/employees/by_id/#{fp_id}")
      end

      return nil unless result.success?

      body = JSON.parse(result.body)

      shift[:fp_name] = "#{body['demographics']['first_name']} #{body['demographics']['last_name']}"

      shift[:groups] = body["groups"].map {|group| group["name"] }

      # Location may be overridden by assigning a site to a shift
      unless shift.key?(:location)
        location = body.dig("demographics", "location")
        return nil if location.blank?

        shift[:location] = "#{location['lat']},#{location['lon']}"
      end
    end

    # include employees that doesn't have any shift assigned
    # @TODO: I don't think this function it's even necessary after we fully replace to matching with local field providers.
    def include_all_users
      result = @wiw_api.get("users")
      return result unless result.success?

      body = JSON.parse(result.body)

      field_providers = body["users"]
      # @TODO: figure out how to do role id dynamic
      field_providers = field_providers.select {|fp| fp["role"] == 3 }

      existing_field_providers = @shifts.pluck(:fp_id).uniq
      new_field_providers = field_providers.reject {|fp| existing_field_providers.include?(fp["employee_code"]) }

      local_fp_hash = get_field_provider_hash(new_field_providers.pluck("employee_code"))

      new_field_providers.each do |fp|
        id = fp["employee_code"]

        local_field_provider = local_fp_hash[id]

        if local_field_provider.present?
          # if there's a local FP saved then use it
          groups = local_field_provider.visits.map {|v| v.patient.demand_partner.name }.uniq
        else
          result = Rails.cache.fetch("ac_field_provider_loc_#{id}", expires_in: 1.day) do
            @alayacare_api.get("employees/employees/by_id/#{id}")
          end

          next unless result.success?

          body = JSON.parse(result.body)
          groups = body["groups"].map {|group| group["name"] }
        end

        @shifts << {
          fp_id:       fp["employee_code"],
          start_time:  Time.zone.now,
          end_time:    Time.zone.now,
          fp_name:     "#{fp['first_name']} #{fp['last_name']}",
          groups:      groups,
          not_working: true # so the front-end knows there's no shift associated to this employee
        }
      end
    end

    def get_field_provider_hash(id_list)
      fps = FieldProvider.includes(:address, {visits: {patient: :demand_partner}})
                         .where(external_id: id_list)
      fps.index_by(&:external_id)
    end

    def get_virtual_provider_roles(resource_requirements)
      return [] if resource_requirements.blank?

      resource_requirements.map do |rr|
        rr[:in_home] ? nil : rr[:provider_role]
      end.compact
    end
  end
end
