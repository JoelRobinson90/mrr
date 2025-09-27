# frozen_string_literal: true

module Visits
  extend ActiveSupport::Concern

  def index_visits(view_name)
    @patient = Patient.find params[:patient_id]
    append_breadcrumb(@patient.full_name)

    render_component view_name, {
      patient_id:   @patient.id,
      current_user: current_user
    }
  end

  included do
    def cancel_visit
      @patient = Patient.find params[:patient_id]
      cancel_code_id = params[:cancel_code_id].instance_of?(Array) ? params[:cancel_code_id][0].to_i : params[:cancel_code_id].to_i
      local_visit = Visit.find_by external_id: params[:external_id]
      successful = false
      cancel_code = CancelCode.find_by id: cancel_code_id

      if cancel_code.blank?
        redirect_to admin_patient_path(@patient), alert: "Cancel code was not found, please try syncing cancel codes."
        return
      end

      successful = local_visit.update(canceled: true, cancel_code_id: cancel_code.id, alayacare_status: "cancelled", visit_group_id: nil)
      redirect_path = params[:redirect_path] || admin_patient_path(@patient)
      redirect_path = field_patient_path(@patient) if current_user.is_field_scheduler?

      if successful
        redirect_to redirect_path, notice: "Visit was cancelled successfully."
      else
        redirect_to redirect_path, alert: "There was an error cancelling the visit."
      end
    end

    def cancel_visit_partial
      cancellation_reasons = Alayacare::CancelCodes.call
      enable_push_to_external = EnvHelper.env_or_nil("ENABLE_PUSH_TO_EXTERNAL")
      
      visit = Visit.find_by external_id: params[:visit_id] if params[:visit_id]
      cancel_code = visit.cancel_code.id if visit.cancel_code

      render_partial_component "PatientCancelVisitCalendarTabPartial",  cancellation_reasons: cancellation_reasons,
                                                                        patient_id:           params[:patient_id],
                                                                        alayacare_visit_id:   params[:alayacare_visit_id],
                                                                        visit:                visit,
                                                                        note:                 visit.admin_notes.where(notable_id: visit.id).last,
                                                                        cancel_code:          cancel_code,
                                                                        current_user:         current_user
    end

    def update_as(user_type)
      authorize! :update, Visit
      redirect_path = user_type == "admin_user" ? admin_patient_path(@visit.patient) : field_patient_path(@visit.patient)

      # Sets a flag that will delete and recreate visit if services were modified.
      @visit.check_for_changed_services(visit_params[:service_ids]) if visit_params.to_h.key? :service_ids

      model_params = visit_params.except(:no_services)
      model_params[:service_ids] = [] if visit_params[:no_services] == "true"

      if @visit.update(model_params)

        Alayacare::UpdateServiceInstructions.call(alayacare_id: nil,
                                                  external_id:  @visit.external_id,
                                                  text:         params[:visit][:service_instructions])
        redirect_to redirect_path, notice: "Visit Updated Successfully"
      else
        redirect_to redirect_path, alert: [@visit.errors.full_messages].flatten
      end
    end
  end
end
