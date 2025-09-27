# frozen_string_literal: true

module Mutations
  class CreateAlayacareVisit < Mutations::AlayacareBaseMutation
    argument :visit_params,
             Types::Params::CreateAlayacareVisitParams,
             required: true
    argument :run_id, String, required: false
    argument :log_string, String, required: false
    argument :scheduling_started_at, String, required: false

    # TODO: return whole visit?
    field :visit_id, ID, null: true
    field :errors, [String], null: false

    def resolve(visit_params:, run_id: nil, log_string: nil, scheduling_started_at: nil)
      visit_params = visit_params.to_h

      visit_resources = visit_params.delete(:resources)
      log_message("CreateVisitMutation: #{run_id} - #{visit_params} - #{log_string}")

      field_provider = FieldProvider.find_by(external_id: visit_params.delete(:field_provider_external_id))

      @visit = Visit.new({**visit_params, field_provider: field_provider})
      return {visit_id: nil, errors: [unauthorized_error]} unless can?(:create, @visit)

      build_resources(@visit, visit_resources)

      scheduler_log = update_scheduler_log(run_id, log_string, scheduling_started_at)

      race_condition_check = if @visit.program&.v2?
                               Routing::CheckRaceCondition.call(@visit)
                             else
                               Alayacare::CheckRaceCondition.call(@visit)
                             end

      unless race_condition_check.success?
        scheduler_log&.update(visit_error_message: race_condition_check.error)
        return {
          visit_id: nil,
          errors:   [race_condition_check.error]
        }
      end

      if @visit.save
        preferred_providers_log_data = update_preferred_providers(@visit.patient, visit_resources, @visit.visit_type)

        Alayacare::UpdateServiceInstructions.call(alayacare_id: nil,
                                                  external_id:  @visit.external_id,
                                                  text:         visit_params[:service_instructions])

        scheduler_log&.update({visit_created: true, visit_id: @visit.id}.merge(preferred_providers_log_data))
        {
          visit_id: @visit.id,
          errors:   []
        }
      else
        scheduler_log&.update(visit_error_message: @visit.errors.full_messages.to_sentence)
        {
          visit_id: nil,
          errors:   @visit.errors.full_messages
        }
      end
    end
  end
end
