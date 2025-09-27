# frozen_string_literal: true

module Queries
  module SchedulerQueries
    include Routing::Helpers

    # TODO: make these variables required in gql schema; fix scheduler page query to load only
    # once these required variables are gathered
    REQUIRED_PARAMS = %i[patient_id program_id visit_type_id service_code_id start_date end_date duration].freeze

    def get_scheduler_data(
      patient_id: nil,
      program_id: nil,
      visit_type_id: nil,
      service_code_id: nil,
      start_date: nil,
      end_date: nil,
      duration: nil,
      top_suggestions: "0",
      limit_arrival_times: nil,
      external_id: nil,
      existing_visit_alayacare_id: nil,
      ignore_existing_visit_conflicts: true
    )
      REQUIRED_PARAMS.each do |param|
        if binding.local_variable_get(param).blank?
          return {
            success:          false,
            suggested_visits: [],
            error_message:    "#{param} needs to be set."
          }
        end
      end

      patient = Patient.find patient_id
      visit_type = VisitType.find visit_type_id
      resource_requirements = visit_type&.visit_resource_requirements

      duration = duration&.to_i
      Rails.logger.debug { "using duration #{duration}" }

      unless patient.address.latitude || patient.address.longitude
        return {
          success:          false,
          suggested_visits: [],
          error_message:    "Unable to retrieve geo-coordinates for this patient's address. Please contact your System Administrator."
        }
      end

      if duration.blank? || duration.zero?
        return {
          success:          false,
          suggested_visits: [],
          error_message:    "Duration needs to be set."
        }
      end

      if limit_arrival_times.to_s == "true"
        visit = Visit.find_by(external_id: external_id)

        if visit.blank?
          return {
            success:          false,
            suggested_visits: [],
            error_message:    "Visit #{external_id} not found."
          }
        end

        start_date = visit.start_time.to_date
        end_date = start_date + 1.day
        if visit.arrival_window_start
          arrival_window = [visit.arrival_window_start, visit.arrival_window_end]
        else
          cx_time = round_time_15(visit.start_time)
          # Apply default arrival window if we don't find one.
          arrival_window = [cx_time - 30.minutes, cx_time + 30.minutes]
        end
      else
        start_date = start_date ? start_date.to_date : Date.today - 1.day
        end_date = end_date ? end_date.to_date : Date.today + 5.weeks
        arrival_window = nil
      end

      fp = current_user.account if current_user.account_type == "FieldProvider"
      fp_id = [fp.external_id] if fp

      route_call = profile("run full visit optimizer wrapper") do
        result = Routing::VisitOptimizerWrapper.call(patient, start_date, end_date, duration,
                                                     current_user: current_user, program_id: program_id,
                                                     existing_visit_id: external_id || existing_visit_alayacare_id,
                                                     fp_ids_to_filter_to: fp_id, arrival_window: arrival_window,
                                                     resource_requirements: resource_requirements,
                                                     ignore_existing_visit_conflicts: ignore_existing_visit_conflicts)
        @run_id = result.dig(:payload, 0, :run_id)
        result
      end

      if route_call.success?
        suggested_visits = route_call.payload

        display_top_suggestions = ActiveRecord::Type::Boolean.new.deserialize(top_suggestions)

        if display_top_suggestions
          # slice to top 3 suggestions
          suggested_visits = suggested_visits.slice(0, 3)
        end
      else
        return {
          success:          false,
          suggested_visits: [],
          error_message:    route_call.error
        }
      end

      if suggested_visits.blank?
        return {
          success:          false,
          suggested_visits: [],
          error_message:    route_call.message
        }
      end

      {
        success:          route_call.success?,
        suggested_visits: suggested_visits,
        shifts:           []
      }
    end

    def get_preferred_providers(patient_id: nil)
      return nil if patient_id.blank?

      patient = Patient.find_by(id: patient_id)
      return nil unless patient && authorized?(:read, patient)

      return patient.preferred_providers_one_per_role.map {|provider|
        {
          fp_id: provider.external_id,
          display_name: "#{provider.role.humanize}: #{provider.full_name}",
          role: provider.role
        }
      }
    end
  end
end
