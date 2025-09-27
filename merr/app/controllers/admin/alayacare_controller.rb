# typed: true
# frozen_string_literal: true

module Admin
  class AlayacareController < BaseController
    include Visits
    load_resource
    skip_before_action :authenticate_medarrive_account!, only: :incoming_event
    skip_before_action :verify_authenticity_token, only: :incoming_event

    def create_visit
      @patient = Patient.find visit_params[:patient_id]

      write_to_scheduler_log

      raw_params = visit_params
      raw_params[:service_ids] = raw_params[:service_ids]&.split(",") || []

      @visit = Visit.new raw_params

      fp = FieldProvider.find_by external_id: params[:field_provider_id]
      @visit.field_provider = fp

      # Check race condition
      race_condition_check = if @visit.program&.v2?
                               Routing::CheckRaceCondition.call(@visit)
                             else
                               Alayacare::CheckRaceCondition.call(@visit)
                             end

      unless race_condition_check.success?
        @scheduler_log&.update(visit_error_message: race_condition_check.error)
        flash[:alert] =
          "There was an error creating the visit, please select another option. (#{race_condition_check.error})"
        redirect_to alayacare_visit_admin_patient_path(@patient, service_code_id: params[:service_code_id])
        return
      end

      if @visit.save
        push_to_external_enabled = EnvHelper.env_or_nil("ENABLE_PUSH_TO_EXTERNAL")

        unless push_to_external_enabled
          push_visit_to_alayacare_manually
          return
        end

        Alayacare::UpdateServiceInstructions.call(alayacare_id: nil,
                                                  external_id:  @visit.external_id,
                                                  text:         visit_params[:service_instructions])

        @scheduler_log&.update(visit_created: true, visit_id: @visit.id)
        flash[:notice] = "Visit was scheduled successfully."
        redirect_to admin_patient_path(@patient)
      else
        @scheduler_log&.update(visit_error_message: @visit.errors.full_messages.to_sentence)
        flash[:alert] =
          "There was an error creating the visit, please select another option. (#{@visit.errors.full_messages})"
        redirect_to alayacare_visit_admin_patient_path(@patient, service_code_id: params[:service_code_id])
      end
    end

    def field_providers
      @start_date = params[:date] ? Date.parse(params[:date]) : Date.today
      @end_date = @start_date + 1.day
      @shifts = Routing::GetShifts.call(@start_date, @end_date).payload
      @appointments = Routing::GetAppointments.call(@start_date, @end_date).payload

      render_component "FieldProviderSchedulesPage",
                       shifts:       @shifts,
                       appointments: @appointments,
                       start_date:   @start_date,
                       end_date:     @end_date
    end

    def cancel_visit_partial
      visit = Visit.find_by external_id: params[:visit_id]

      unless visit
        render_partial_component "PatientCancelVisitCalendarTabPartial", cancellation_reasons: [],
                                                              patient_id:           params[:patient_id],
                                                              alayacare_visit_id:   params[:alayacare_visit_id],
                                                              visit:                nil,
                                                              current_user:         current_user
        return
      end
      cancel_code = visit.cancel_code.id if visit.cancel_code

      cancellation_reasons = visit.program.v2? ? CancelCode.v2 : CancelCode.v1
      cancellation_reasons = cancellation_reasons.all.map {|c| c.to_builder.attributes! }
      render_partial_component "PatientCancelVisitCalendarTabPartial",  cancellation_reasons: cancellation_reasons,
                                                                        patient_id:           params[:patient_id],
                                                                        alayacare_visit_id:   params[:alayacare_visit_id],
                                                                        visit:                visit,
                                                                        note:                 visit.admin_notes.where(notable_id: visit.id).last,
                                                                        cancel_code:          cancel_code,
                                                                        current_user:         current_user
    end

    def edit_visit
      @patient = Patient.find params[:patient_id]

      result = Alayacare::UpdateServiceInstructions.call(alayacare_id: params[:alayacare_visit_id],
                                                         external_id:  nil,
                                                         text:         params[:visit][:service_instructions])
      if result.success?
        redirect_to admin_patient_path(@patient), notice: "Visit was updated successfully."
      else
        redirect_to admin_patient_path(@patient),
                    alert: "There was an error updating the visit. (#{result.error})"
      end
    end

    def incoming_event
      log_prefix = "SQS event processor:"
      Rails.logger.info "#{log_prefix} Incoming event #{params}"

      # Ignore unrelated events
      unless params[:source] == "alayacare" &&
             params[:source_channel] == "sqs" &&
             (%w[visit-updated visit-clock-in visit-clock-out].include? params.dig(:payload, :event))
        render plain: "Success"
        return
      end

      # Authorize
      if params[:shared_secret] != EnvHelper.env_or_nil("SQS_SHARED_SECRET")
        Rails.logger.error "#{log_prefix} UNAUTHORIZED. Incorrect key: #{params[:shared_secret]}"
        render plain: "unauthorized", status: :unauthorized
        return
      end

      # Check payload
      payload = params[:payload]
      if payload.blank?
        Rails.logger.error "#{log_prefix} Bad request.  Missing payload: #{params}"
        render plain: "unauthorized", status: :bad_request
        return
      end

      result = Alayacare::VisitUpdatedEventHandler.call(payload["external_id"])

      if result.success?
        render plain: "Success"
      else
        render plain: result.error, status: :internal_server_error
      end
    end

    private

    def write_to_scheduler_log
      return if params[:run_id].blank?

      @scheduler_log = SchedulerLog.find_by(run_id: params[:run_id])

      if @scheduler_log
        log_hash = {
          picks_before_booking: params[:total_number_of_picks],
          index_chosen:         params[:ranking],
          drive_time_chosen:    params[:drive_time],
          start_time_chosen:    params[:start_time],
          end_time_chosen:      params[:end_time],
          field_provider_name:  params[:field_provider_name],
          total_score:          params[:total_score],
          drive_score:          params[:drive_score],
          proximity_score:      params[:proximity_score],
          utilization_score:    params[:utilization_score]
        }

        if params[:scheduling_started_at]
          elapsed_time = (Time.zone.now - Time.zone.parse(params[:scheduling_started_at])) / 60
          log_hash[:elapsed_time_for_choice] = elapsed_time
        end

        @scheduler_log.update(log_hash)
      end
    end

    def visit_params
      params.require(:visit).permit(:start_time, :end_time, :service_instructions, :external_id, :service_ids,
                                    :patient_id, :program_id, :visit_type_id)
    end

    def push_visit_to_alayacare_manually
      create_visit_resp = Alayacare::PushVisit.call(:create, @visit)

      if create_visit_resp.success?
        @scheduler_log&.update(visit_created: true)
        flash[:notice] = "Visit was scheduled successfully."
        redirect_to admin_patient_path(@patient)
      else
        @scheduler_log&.update(visit_error_message: create_visit_resp.error)
        redirect_to alayacare_visit_admin_patient_path(@patient, service_code_id: params[:service_code_id])
        flash[:alert] =
          "There was an error creating the visit, please select another option. (#{create_visit_resp&.error || create_visit_resp&.body})"
      end
    end
  end
end
