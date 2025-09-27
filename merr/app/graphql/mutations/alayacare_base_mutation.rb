# frozen_string_literal: true

module Mutations
  class AlayacareBaseMutation < Mutations::BaseMutation
    PROTECTED_SCHEDULER_LOG_ATTRS = %w[
      id
      created_at
      updated_at
      patient_id
      user_id
      run_id
      visit_id
    ].freeze

    def update_scheduler_log(run_id, log_string, scheduling_started_at, additional_params = {})
      return nil if run_id.blank?

      scheduler_log = SchedulerLog.find_by(run_id: run_id)

      if scheduler_log && (log_hash = scheduler_log_params(log_string))
        if scheduling_started_at
          elapsed_time = (Time.zone.now - Time.zone.parse(scheduling_started_at)) / 60
          log_hash["elapsed_time_for_choice"] = elapsed_time
        end

        unless scheduler_log.update(log_hash.merge(additional_params))
          log_message("SchedulerLog update failed: #{scheduler_log.errors&.full_messages&.to_sentence}")
        end
      else
        log_message("SchedulerLog not found: #{run_id} - #{log_string}")
      end

      scheduler_log
    end

    def build_resources(visit, visit_resources)
      visit_resources.each do |resource|
        provider = FieldProvider.find_by(external_id: resource[:resource_id])
        visit.visit_resources.build({
                                      field_provider: provider,
                                      start_time:     resource[:start_time],
                                      end_time:       resource[:end_time],
                                      in_home:        resource[:in_home]
                                    })
      end
    end

    def update_preferred_providers(patient, visit_resources, visit_type)
      preferred_providers = patient.preferred_providers

      visit_providers = visit_resources.map {|resource| FieldProvider.find_by(external_id: resource[:resource_id]) }

      any_preferred = false
      all_preferred = true

      visit_providers.each do |visit_provider|
        if preferred_providers.map(&:id).include? visit_provider.id
          any_preferred = true
        else
          all_preferred = false
        end

        unless preferred_providers.map(&:role).include?(visit_provider.role)
          ProviderPreference.create(patient: patient, field_provider: visit_provider)
        end
      end

      {
        full_preferred_provider_option_chosen:    all_preferred,
        partial_preferred_provider_option_chosen: any_preferred
      }
    end

    private

    def scheduler_log_params(json_string)
      return nil if json_string.blank?

      JSON.parse(json_string).slice(*permitted_scheduler_log_attrs)
    rescue JSON::ParserError
      nil
    end

    def permitted_scheduler_log_attrs
      SchedulerLog.attribute_names - PROTECTED_SCHEDULER_LOG_ATTRS
    end
  end
end
