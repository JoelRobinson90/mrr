# frozen_string_literal: true

module Patients
  extend ActiveSupport::Concern
  include Routing::Helpers

  # *LJA these two index_by functions probably dont need to exist in concerns anymore since they're separate, but its nice to have them together for comparison for the moment
  def index_for_external_users_by(view_name, fp_id: nil, pt_programs: [])
    @patients = @patients
                .includes(:address)
                .paginate(page: @current_page, per_page: @per_page)
                .order(created_at: :desc)

    if fp_id
      fp_visits = Visit.where(field_provider_id: current_user[:account_id])
      ids = []
      fp_visits.each do |visit|
        ids << visit[:patient_id]
      end
      @patients = @patients.where(id: ids)
    elsif pt_programs.length.positive?
      @patients = @patients.includes(:patient_programs).where(patient_programs: {program_id: pt_programs})
    end

    @patients = @patients.where.not(status: "Archived") unless @filters[:status]&.include? "Archived"

    @patients = @patients.text_search(query: params[:s], external: true) if params[:s].present?
    @patients = @patients.where(status: @filters[:status]) if @filters[:status]
    @patients = @patients.where(demand_partner: {id: @filters[:demand_partner]}) if @filters[:demand_partner]

    render_component view_name, {
      patients:        @patients.as_json(methods: %i[display_phone_number],
                                         include: {
                                           address: {only: %i[city state]}
                                         },
                                         except:  [:tag_list]),
      query:           params[:s],
      statuses:        PatientConstants::STATUSES,
      pagination:      pagination_props(@patients),
      demand_partners: DemandPartner.select(:id, :name),
      filters:         @filters,
      current_user:    current_user
    }
  end

  # *LJA probably dont need pt_programs argument in here anymore since that was used for external users only, I think
  def index_by(view_name, fp_id: nil, pt_programs: [])
    @patients = @patients
                .includes(:address, :demand_partner, :tags, :custom_field_responses, :programs)
                .paginate(page: @current_page, per_page: @per_page)
                .order(created_at: :desc)

    if fp_id
      fp_visits = Visit.where(field_provider_id: current_user[:account_id])
      ids = []
      fp_visits.each do |visit|
        ids << visit[:patient_id]
      end
      @patients = @patients.where(id: ids)
    elsif pt_programs.length.positive?
      @patients = @patients.includes(:programs).where(programs: {id: pt_programs})
    end

    @patients = @patients.where.not(status: "Archived") unless @filters[:status]&.include? "Archived"

    @patients = @patients.text_search(query: params[:s]) if params[:s].present?
    @patients = @patients.where(status: @filters[:status]) if @filters[:status]
    @patients = @patients.where(demand_partner: {id: @filters[:demand_partner]}) if @filters[:demand_partner]

    render_component view_name, {
      patients:        @patients.as_json(methods: %i[tags display_phone_number],
                                         include: {
                                           address:        {only: %i[city state]},
                                           demand_partner: {only: [:name]}
                                         },
                                         except:  [:tag_list]),
      query:           params[:s],
      statuses:        PatientConstants::STATUSES,
      pagination:      pagination_props(@patients),
      demand_partners: DemandPartner.select(:id, :name),
      filters:         @filters,
      current_user:    current_user
    }
  end

  def show_with(view_name)
    append_breadcrumb(@patient.full_name)
    @paper_trail = PaperTrailScrapbook::LifeHistory.new(@patient).story

    demand_partners = DemandPartner.all
    metadata = {
      demand_partners: demand_partners,
      genders:         Patient::GENDERS,
      sexes:           Patient::SEXES,
      pronouns:        Patient::PREFERRED_PRONOUNS,
      races:           Patient::RACES,
      ethnicities:     Patient::ETHNICITY,
      languages:       Patient::LANGUAGES_LONGFORM,
      phone_types:     Patient::PHONE_TYPES
    }

    if current_user.is_external_account?
      programs = @patient.programs.where(active: true).select do |program|
        current_user.account.program_ids.include?(program.id)
      end
      all_programs = current_user.account.programs.includes(:demand_partner)
    else
      programs = @patient.programs
      all_programs = Program.includes(:demand_partner).all
    end

    service_requests = @patient.service_requests.select do |service_request|
      service_request.refresh_status == "requested"
    end

    render_component view_name,
                     current_user:     current_user.to_builder.attributes!,
                     patient:          @patient.to_builder(include_admin_notes: true, include_insurances: true,
                                                           include_clinical_summary: true,
                                                           include_latest_order: true,
                                                           include_custom_field_responses: true, include_programs: true).attributes!,
                     dropdownOptions:  metadata,
                     paper_trail:      @paper_trail,
                     statuses:         Patient::STATUSES,
                     patient_programs: programs.map {|p| p.to_builder.attributes! },
                     all_programs:     all_programs.map {|p|
                                         p.to_builder(include_demand_partner = true, include_services = false,
                                                      include_visit_types = false).attributes!
                                       },
                     added_visit_id:   params[:added_visit_id],
                     service_requests: service_requests.map {|req| req.to_builder.attributes! }
  end

  def update_with
    authorize! :update, @patient
    assign_patient_attributes(@patient)

    @patient.update_alayacare_in_foreground = true
    if @patient.save
      if current_user.is_external_account?
        redirect_to field_patient_path(@patient), notice: "Patient updated"
      else
        redirect_to admin_patient_path(@patient), notice: "Patient updated"
      end
    else
      flash[:alert] = [@patient.errors.full_messages].flatten
      if current_user.is_external_account?
        redirect_to field_patient_path(@patient)
      else
        redirect_to admin_patient_path(@patient)
      end
    end
  end

  # @TODO: to be removed since Graphql took over
  def fetch_suggested_visits
    duration = params[:duration]&.to_i
    Rails.logger.debug { "using duration #{duration}" }
    if duration.blank? || duration.zero?
      render json: {
        success:          false,
        suggested_visits: [],
        error_message:    "Duration needs to be set."
      }
      return
    end

    if params[:limit_arrival_times].to_s == "true"
      visit = Visit.find_by(external_id: params[:external_id])

      if visit.blank?
        render json: {
          success:          false,
          suggested_visits: [],
          error_message:    "Visit #{params[:external_id]} not found."
        }
        return
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
      start_date = params[:start_date] ? params[:start_date].to_date : Date.today - 1.day
      end_date = params[:end_date] ? params[:end_date].to_date : Date.today + 5.weeks
      arrival_window = nil
    end

    fp = current_user.account if current_user.account_type == "FieldProvider"
    fp_id = [fp.external_id] if fp

    route_call = profile("run full visit optimizer wrapper") do
      result = Routing::VisitOptimizerWrapper.call(@patient, start_date, end_date, duration,
                                                   current_user: current_user, program_id: params[:program_id],
                                                   existing_visit_id: params[:external_id] || params[:existing_visit_alayacare_id],
                                                   fp_ids_to_filter_to: fp_id, arrival_window: arrival_window)
      @run_id = result.dig(:payload, 0, :run_id)
      result
    end

    if route_call.success?
      suggested_visits = route_call.payload

      display_top_suggestions = ActiveRecord::Type::Boolean.new.deserialize(params[:top_suggestions])

      if display_top_suggestions
        # slice to top 3 suggestions
        suggested_visits = suggested_visits.slice(0, 3)
      end
    else
      render json: {
        success:          false,
        suggested_visits: [],
        error_message:    route_call.error
      }
      return
    end

    if suggested_visits.blank?
      render json: {
        success:          false,
        suggested_visits: [],
        error_message:    route_call.message
      }
      return
    end

    render json: {
      success:          route_call.success?,
      suggested_visits: suggested_visits,
      shifts:           []
    }
  end

  # @TODO: to be removed since Graphql took over this.
  def fetch_visit_param_info
    program = Program.find_by(id: params[:program_id])
    visit_type = VisitType.find_by(id: params[:visit_type_id])
    services = Service.where(id: params[:service_ids].split(",")) if params[:service_ids]
    visit_info = {}

    # @TODO: replace internal_visit_id with ma visit id from FE
    response = Alayacare::FetchVisit.call(params[:existing_visit_alayacare_id],
                                          internal_visit_id: params[:external_id])

    visit = response.success? ? response.payload : nil

    if program && visit_type && services
      visit_info = {
        program:    program,
        visit_type: visit_type,
        services:   services
      }
    end

    visit_info[:existing_visit] = visit if visit

    if visit_info.blank?
      render json: {
        success:       false,
        visit_info:    {},
        error_message: "Couldn't find a program, visit type, or appropriate services."
      }
      return
    end

    render json: {
      success:    true,
      visit_info: visit_info
    }
  end

  def edit_visit_partial
    visit = Visit.find_by external_id: params[:visit_id]

    return [] if visit.blank?

    visit_program = visit.program.to_builder.attributes!
    
    # The visit_type on Visits that are plus-ones is only allowed to be edited to another visit_type with plus-ones enabled
    visit_types = visit_program["visit_types"]
    if visit.visit_type["plus_ones_enabled"] == true
      visit_program["visit_types"] = visit_types.find_all {|visit_type| visit_type["plus_ones_enabled"] == true}
    end

    visit = {
      alayacare_visit_id:   nil,
      field_provider:       {
        first_name: visit.field_provider.present? ? visit.field_provider.full_name : "No Field Provider"
      },
      start_time:           visit.start_time,
      end_time:             visit.end_time,
      service_code_name:    visit.visit_type.name,
      canceled:             visit.canceled,
      cancel_reason:        visit.canceled ? visit.cancel_code&.code : "",
      services:             visit.services.map {|s| s.to_builder.attributes! },
      service_instructions: visit.service_instructions,
      local:                true,
      local_visit_id:       visit.id,
      visit_type_id:        visit.visit_type_id,
      cx_start:             round_time_15(visit.start_time),
      cx_end:               round_time_15(visit.end_time),
      visit_group_id:       visit.visit_group_id,
      external_id:          visit.external_id,
      status:               visit.status,
      program_id:           visit.program_id
    }

    render_partial_component "EditVisitPartial", visit: visit, program_services: visit_program["services"],
      patient: @patient.to_builder.attributes!, visit_types: visit_program["visit_types"], current_user: current_user
  end

  private

  def filters
    %i[status demand_partner]
  end

  def assign_patient_attributes(patient)
    update_params = patient_params

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

  def patient_params
    user_params = %i[id email password password_confirmation]
    address_params = %i[id address_line_one address_line_two county city state zipcode notes]
    pharmacies_params = [:id, :name, :phone_number, :_destroy, {address_attributes: address_params}]
    custom_field_responses_params = %i[id value]
    programs_params = %i[id name]
    
    insurances_params = %i[id name member_id group_id bin_number rx_pcn rx_group _destroy]

    params.require(:patient).permit(:consent_to_email, :preferred_contact_method, :first_name, :last_name, :phone, :date_of_birth, :middle_initial, :phone_number, :phone_number_type, :contact_email,
                                    :consent_to_text, :secondary_phone_number, :secondary_phone_number_type, :medical_record_number,
                                    :emergency_contact_name, :emergency_contact_phone_number, :demand_partner_id, :patient_notes,
                                    :primary_care_physician_id, :sex, :gender, :preferred_pronouns, :preferred_language, :race, :ethnicity, :primary_risk_category,
                                    pharmacies_attributes: pharmacies_params, custom_field_responses_attributes: custom_field_responses_params, address_attributes: address_params,
                                    user_attributes: user_params, insurances_attributes: insurances_params, patient_programs_attributes: programs_params, program_ids: [])
  end
end
