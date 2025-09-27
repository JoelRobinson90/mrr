# frozen_string_literal: true

module Mutations
  class RescheduleVisit < Mutations::AlayacareBaseMutation
    argument :visit_params,
             Types::Params::RescheduleVisitParams,
             required: true
    argument :run_id, String, required: false
    argument :log_string, String, required: false

    # TODO: return whole visit?
    field :visit_id, ID, null: true
    field :errors, [String], null: false

    def resolve(visit_params:, run_id: nil, log_string: nil)
      # from controller
      visit_params = visit_params.to_h
      log_message("RescheduleCanceledMutation: #{run_id} - #{visit_params} - #{log_string}")

      visit_resources = visit_params.delete(:resources)

      @existing_visit = Visit.find_by(external_id: visit_params[:external_id])

      field_provider = FieldProvider.find_by(external_id: visit_params[:field_provider_id])

      response = Routing::RescheduleCancelledVisit.call(visit: @existing_visit, start_time: visit_params[:start_time],
                                                        end_time: visit_params[:end_time], field_provider: field_provider,
                                                        resources: visit_resources)

      update_scheduler_log(run_id, log_string, nil, {rescheduling: true,
                                                     visit_created: response.success?,
                                                     visit_id: response&.payload&.id})

      if response.success?
        {
          visit_id: response.payload&.id,
          errors:   [] # populate errors here
        }
      else
        {
          visit_id: nil,
          errors:   [response.error]
        }
      end
    end
  end
end
