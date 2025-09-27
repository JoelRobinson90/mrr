# typed: true
# frozen_string_literal: true

module Admin
  class PatientsController < BaseController
    include Routing::Helpers
    include Patients

    before_action :load_patient_with_associations, only: %w[show history]
    load_resource except: %w[show history]
    authorize_resource except: %i[admin_notes history update_status]

    def show
      show_with("PatientShowPage")
    end

    def index
      index_by("PatientIndexPage")
    end

    def new
      @patient = Patient.new
      render_component "PatientCreatePage", build_patient_form_metadata(@patient)
    end

    def edit
      show
    end

    def create
      authorize! :create, Patient
      @patient = Patient.new

      assign_patient_attributes(@patient)
      @patient.update_alayacare_in_foreground = true
      if @patient.save
        redirect_to admin_patient_path(@patient), notice: "Patient created"
      else
        flash[:alert] = [@patient.errors.full_messages].flatten
        render_component "PatientCreatePage", build_patient_form_metadata(@patient)
      end
    end

    def update
      update_with
    end

    def admin_notes
      authorize! :create, AdminNote
      admin_note = @patient.admin_notes.build(admin_note_params)
      if admin_note.save
        flash[:notice] = "Admin note was saved successfully."
      else
        flash[:alert] = [admin_note.errors.full_messages].flatten
      end
      redirect_to admin_patient_path(@patient)
    end

    def visit_notes
      authorize! :create, AdminNote
      @patient = Patient.find admin_note_params[:patient_id]
      @current_user = User.find admin_note_params[:current_user_id]

      resp = Alayacare::CreateExternalVisitNote.call(admin_note_params[:alayacare_visit_id],
                                                     admin_note_params[:content], @current_user)

      if resp.success?
        flash[:notice] = "Admin note was saved successfully."
      else
        flash[:alert] = [admin_note.errors.full_messages].flatten
      end
      redirect_to admin_patient_path(@patient)
    end

    def history
      authorize! :read, @patient
      @history = PatientHistory.new(@patient).execute.to_json
      render_component "PatientHistoryPage", history: @history
    end

    def update_status
      authorize! :update, @patient
      if @patient.update(update_status_params)
        redirect_to admin_patient_path(@patient), notice: "Patient Updated"
      else
        flash[:alert] = [@patient.errors.full_messages].flatten
        redirect_to admin_patient_path(@patient)
      end
    end

    def alayacare_visit
      alayacare_client = Alayacare::ApiClient.new
      service_codes = alayacare_client.service_codes

      render_component "AlayacareCreateVisit", {
        patient:       @patient.to_builder.attributes!,
        service_codes: service_codes,
        programs:      @patient.programs.includes(%i[demand_partner services]).map {|p| p.to_builder.attributes! },
        enable_form:   true
      }
    end

    def visit_types
      program = @patient.programs.find_by(id: params[:program_id])
      visit_types = program.visit_types
      render json: {
        visit_types: visit_types.map {|v| v.to_builder.attributes! }
      }
    end

    private

    def assign_patient_attributes(patient)
      update_params = patient_params

      update_params[:program_ids] ||= []

      # filter out user attributes unless email present
      user_email = update_params.dig(:user_attributes, :email)
      update_params = update_params.except(:user_attributes) if user_email.blank?

      # filter out address attributes unless address is present
      address = update_params.dig(:address_attributes, :address_line_one)
      update_params = update_params.except(:address_attributes) if address.blank?

      # filter out blank values that are part of a validated set
      %i[sex gender preferred_pronouns preferred_language race ethnicity].each do |attribute|
        update_params = update_params.except(attribute) if update_params[attribute].blank?
      end

      # actually update values
      patient.assign_attributes(update_params)

      # make sure user is valid before saving
      patient.user.assign_random_password if patient.user && patient.user.password.blank?
    end

    def load_patient_with_associations
      query = Patient.includes(:user, :address, {insurances: :versions}, {visits: :versions},
                               {programs: %i[demand_partner services visit_types]})
      
      # Load by DB id or ma_id
      @patient = if params[:id]&.downcase&.include?("patient")
        query.find_by!(ma_id: params[:id])
      else
        query.find(params[:id])
      end
    end

    def render_clinical_summary_pdf
      respond_to do |format|
        format.html
      end
      false
    end

    # Only allow a list of trusted parameters through.
    def patient_params
      user_params = %i[id email password password_confirmation]
      address_params = %i[id address_line_one address_line_two county city state zipcode notes]
      pharmacies_params = [:id, :name, :phone_number, :_destroy, {address_attributes: address_params}]
      custom_field_responses_params = %i[id value]
      programs_params = %i[id name]

      insurances_params = %i[id name member_id group_id bin_number rx_pcn rx_group _destroy]

      params.require(:patient).permit(:first_name, :last_name, :phone, :date_of_birth, :middle_initial, :phone_number, :phone_number_type, :contact_email,
                                      :consent_to_text, :consent_to_email, :secondary_phone_number, :secondary_phone_number_type, :medical_record_number,
                                      :emergency_contact_name, :emergency_contact_phone_number, :demand_partner_id, :patient_notes,
                                      :primary_care_physician_id, :sex, :gender, :preferred_pronouns, :preferred_language, :race, :ethnicity, :preferred_contact_method, :primary_risk_category,
                                      pharmacies_attributes: pharmacies_params, custom_field_responses_attributes: custom_field_responses_params, address_attributes: address_params,
                                      user_attributes: user_params, insurances_attributes: insurances_params, patient_programs_attributes: programs_params, program_ids: [])
    end

    def admin_note_params
      params.require(:admin_note).permit(:content, :creator_id, :alayacare_visit_id, :patient_id, :current_user_id)
    end

    def build_patient_form_metadata(patient)
      # @TODO: should demand partners typeahead in the front instead ?
      demand_partners = DemandPartner.all
      metadata = {
        patient:         patient.to_builder(include_admin_notes: true, include_insurances: true,
                                            include_custom_field_responses: true, include_programs: true).attributes!,
        demand_partners: demand_partners,
        genders:         Patient::GENDERS,
        sexes:           Patient::SEXES,
        pronouns:        Patient::PREFERRED_PRONOUNS,
        races:           Patient::RACES,
        ethnicities:     Patient::ETHNICITY,
        languages:       Patient::LANGUAGES_LONGFORM,
        phone_types:     Patient::PHONE_TYPES,
        programs:        Program.all.map {|p| p.to_builder.attributes! }
      }
      if patient.persisted?
        metadata[:pharmacies] = patient.pharmacies.includes(:address).as_json(
          include: [:address]
        )
        metadata[:custom_field_responses] = patient.custom_field_responses
        metadata[:address] = patient.address
        metadata[:user] = patient.user
      end

      metadata
    end

    def update_status_params
      params.require(:patient).permit(:status)
    end

    def filters
      %i[status demand_partner]
    end

    def enable_session_filters?
      true
    end
  end
end
