# typed: true
# frozen_string_literal: true

module Field
  class PatientsController < BaseController
    include Routing::Helpers
    include Patients

    before_action :load_patient_with_associations, only: %w[show history]
    load_resource except: %w[show history]
    authorize_resource except: %i[admin_notes history update_status]

    def index
      if current_user.is_external_account?
        index_for_external_users_by("FieldSchedulerPatientIndexPage", pt_programs: current_user.account.program_ids)
      else
        index_by("FieldSchedulerPatientIndexPage", fp_id: current_user[:account_id])
      end
    end

    def show
      show_with("FieldSchedulerPatientShowPage")
    end

    def update
      update_with
    end

    private

    def load_patient_with_associations
      @patient = Patient.includes(:user, :address, {insurances: :versions}, {appointments: :versions}).find(params[:id])
    end
  end
end
