# frozen_string_literal: true

class SfdcExternalController < ApplicationController
  # For SFDC scheduler demo
  # temp_auth_token and patient_external_id params required to access scheduler
  def scheduler_entrypoint
    return head :unauthorized unless sfdc_iframe_authorized?

    @patient = Patient.where(external_id: params[:patient_external_id]).first

    return render plain: "No patient found with ID #{params[:patient_external_id]}", status: :not_found unless @patient

    redirect_to admin_patient_visits_path(@patient, params: {iframe: 1, temp_auth_token: temp_auth_token})
  end
end
