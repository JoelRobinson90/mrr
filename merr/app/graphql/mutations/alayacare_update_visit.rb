# frozen_string_literal: true

module Mutations
  class AlayacareUpdateVisit < Mutations::AlayacareBaseMutation
    argument :visit_params,
             Types::Params::UpdateAlayacareVisitParams,
             required: true
    argument :run_id, String, required: false
    argument :log_string, String, required: false

    field :visit, Types::VisitType, null: true
    field :errors, [String], null: false

    def resolve(visit_params:, run_id: nil, log_string: nil)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)

      # from controller
      visit_params = visit_params.to_h
      log_message("UpdateVisitMutation: #{run_id} - #{visit_params} - #{log_string}")

      visit_resources = visit_params.delete(:resources)

      scheduler_log = update_scheduler_log(run_id, log_string, nil, {"rescheduling" => true})

      # if visit is being rescheduled, the only internal status applicable is 'scheduled'
      visit_params[:status] = "scheduled"
      visit_params[:canceled] = false
      visit_params[:cancel_code_id] = nil

      @existing_visit = Visit.find_by(external_id: visit_params[:external_id])

      visit_params[:field_provider_id] = FieldProvider.find_by(external_id: visit_params[:field_provider_id])&.id
      visit_params[:field_provider_id] = @existing_visit.field_provider_id if visit_params[:field_provider_id].blank?

      if visit_resources.present?
        @existing_visit.visit_resources.destroy_all
        build_resources(@existing_visit, visit_resources)
      end

      # if the visit has +1 patients
      if @existing_visit.visit_group.present?
        visit_group_visits = @existing_visit.visit_group.visits
        # removes current visit from the visits inside visit group
        visit_group_visits = visit_group_visits.reject {|v| v.id == @existing_visit.id }

        if visit_group_visits.size == 1
          # if after removing existing visit the visit group only have 1 visit left then delete visit group
          visit_group_visits.first.visit_group.destroy
        end

        # removes visit group from existing visit to avoid carrying over +1 patients
        @existing_visit.visit_group_id = nil
      end

      # if visit was cancelled and is becoming not cancelled, we need to fetch AC data for appropriate status
      if @existing_visit[:canceled] && !visit_params[:canceled]
        body = {}
        body[:cancelled] = false
        body[:cancel_code_id] = nil

        result = @api.put("scheduler/visits/by_id/#{visit_params[:external_id]}", body)
        parsed_response = JSON.parse(result.body)
        visit_params[:alayacare_status] = parsed_response["status"]
        visit_params[:cancel_code_id] = nil
      end

      if @existing_visit.update(visit_params.except(:alayacare_visit_id))
        preferred_providers_log_data = update_preferred_providers(@existing_visit.patient, visit_resources,
                                                                  @existing_visit.visit_type)

        Alayacare::UpdateServiceInstructions.call(alayacare_id: nil,
                                                  external_id:  @existing_visit.external_id,
                                                  text:         visit_params[:service_instructions])

        scheduler_log&.update({visit_created: true, visit_id: @existing_visit.id}.merge(preferred_providers_log_data))
        {
          visit:  @existing_visit,
          errors: []
        }
      else
        scheduler_log&.update(visit_error_message: @existing_visit.errors.full_messages.to_sentence)
        {
          visit:  nil,
          errors: @existing_visit.errors.full_messages
        }
      end
    end
  end
end
