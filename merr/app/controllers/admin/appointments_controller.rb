# typed: true
# frozen_string_literal: true

module Admin
  class AppointmentsController < BaseController
    before_action :set_appointment, only: %i[show]

    load_resource
    authorize_resource except: %i[edit_partial fetch_clinical_summary tags admin_notes visit_results]

    def index
      flash[:notice] = "asdf"
      @appointments = @appointments
                      .includes(:tags, :taggings, {patient: [:demand_partner]}, :address, :field_provider, :covid_vaccination, :extra_vaccine_recipients)
                      .order(created_at: :desc)

      @appointments = @appointments.where.not(status: "Archived") unless @filters[:status]&.include? "Archived"

      @appointments = @appointments.search(params[:s]) if params[:s].present?
      @appointments = @appointments.where(status: @filters[:status]) if @filters[:status]
      @appointments = @appointments.where(demand_partner: {id: @filters[:demand_partner]}) if @filters[:demand_partner]
      @appointments = @appointments.tagged_with(@filters[:tag], any: true) if @filters[:tag]
      if @filters[:start] && @filters[:end]
        zone = Time.find_zone(@filters[:timezone])
        redirect_to admin_appointments_path, alert: "Timezone not recognized" and return if zone.blank?

        date_range = zone.parse(@filters[:start]).beginning_of_day..zone.parse(@filters[:end]).end_of_day

        @appointments = @appointments
                        .where(start_time: date_range)

      end

      # must happen before pagination
      appointments_count = @appointments.count

      @appointments = @appointments.paginate(page: @current_page, per_page: @per_page)

      render_component "AppointmentIndexPage", {
        appointments:       @appointments.as_json(
          methods: %i[tag_list vaccine_quantity],
          include: {
            tags:              {only: %i[name color]},
            covid_vaccination: {only: %i[vaccine_type]},
            address:           {},
            field_provider:    {only: %i[display_name provider_level avatar], methods: %i[display_name]},
            patient:           {
              only:    %i[id display_name consent_to_text],
              methods: %i[id display_name consent_to_text display_phone_number],
              include: {
                demand_partner: {only: %i[name]}
              }
            }
          }
        ),
        pagination:         pagination_props(@appointments),
        statuses:           Appointment::STATUSES,
        available_tags:     Appointment.available_tags.map(&:name),
        demand_partners:    DemandPartner.select(:id, :name),
        filters:            @filters,
        query:              params[:s],
        appointments_count: appointments_count
      }
    end

    def show
      authorize! :read, @appointment
      append_breadcrumb(@appointment.patient.full_name)

      @appointment_paper_trail = PaperTrailScrapbook::LifeHistory.new(@appointment).story


      extra_vaccine_history = @appointment.extra_vaccine_recipients.collect(&:paper_trail_history)
      covid_vaccination_history = @appointment.covid_vaccination.paper_trail_history if @appointment.covid_vaccination
      combined_paper_trail = @appointment_paper_trail 
      extra_vaccine_history.flatten(1).each {|extra| combined_paper_trail.push(extra) }
      covid_vaccination_history&.each {|c| combined_paper_trail.push(c) }

      @field_providers = FieldProvider.all.select(:first_name, :last_name, :id)
      render_component "AppointmentShowPage",
                       appointment:     @appointment.to_builder(include_admin_notes:              true,
                                                                include_extra_vaccine_recipients: true,
                                                                include_hra_survey:               true,
                                                                include_order:                    true,
                                                                include_available_surveys:        true).attributes!,
                       paper_trail:     combined_paper_trail,
                       statuses:        Appointment::STATUSES,
                       available_tags:  Appointment.available_tags.map(&:name),
                       field_providers: @field_providers.as_json(only: [:id], methods: [:display_name])
    end

    def new
      if params[:patient_id].blank?
        redirect_to request.referer, alert: "Can not create appointment without patient"
        return
      end

      @patient = Patient.find(params[:patient_id])
      authorize! :read, @patient

      @appointment = Appointment.new(status: "Created", patient: @patient)

      @appointment.build_address(@patient.address.dup.attributes.compact) if @patient.address.present?

      render_component "AppointmentEditPage",
                       appointment:    @appointment.to_builder(include_extra_vaccine_recipients: true).attributes!,
                       statuses:       Appointment::STATUSES,
                       available_tags: Appointment.available_tags.map(&:name)
    end

    def edit
      render_component "AppointmentEditPage",
                       appointment:    @appointment.to_builder(include_extra_vaccine_recipients: true).attributes!,
                       statuses:       Appointment::STATUSES,
                       available_tags: Appointment.available_tags.map(&:name)
    end

    def edit_partial
      authorize! :update, @appointment
      render_partial_component "AppointmentEditPartial",
                               appointment:    @appointment.to_builder(include_extra_vaccine_recipients: true).attributes!,
                               available_tags: Appointment.available_tags.map(&:name)
    end

    def admin_notes
      authorize! :create, AdminNote

      admin_note = @appointment.admin_notes.build(admin_note_params)
      if admin_note.save
        flash[:notice] = "Admin note was saved successfully."
      else
        flash[:alert] = [admin_note.errors.full_messages].flatten
      end
      redirect_to admin_appointment_path(@appointment)
    end

    def fetch_clinical_summary
      authorize! :update, @appointment.patient

      order = @appointment.order

      if order.blank?
        redirect_to admin_appointment_path(@appointment), alert: "No order for this appointment"
        return
      end

      result = false

      if result.success?
        flash[:notice] = "Fetched clinical summary"
      else
        flash[:alert] = "Could not fetch clinical summary: #{result.error}"
      end

      redirect_to admin_appointment_path(@appointment)
    end

    # TODO: temporary for test button
    def send_pdf; end

    # TODO: as soon as we have an appointment edit action for admins then we can just use that action
    # as long as it's in the strong params.
    def tags
      authorize! :update, @appointment

      update_params = appointment_params

      # TODO: This should be fixed by making sure MedComboBox sends back an empty value in an array
      # when there are no items selected.
      update_params[:tag_list] ||= []

      if @appointment.update(update_params)
        flash[:notice] = "Updated tags"
      else
        flash[:alert] = "Could not save appointment: #{@appointment.errors.full_messages.to_sentence}"
      end

      redirect_to admin_appointment_path(@appointment)
    end

    def visit_results
      authorize! :read, @appointment

      order = @appointment.order
      if order.blank?
        redirect_to admin_appointment_path(@appointment), alert: "No order for this appointment"
        return
      end

      visit_results = appointment_params[:visit_results]

      result = false

      if result.success?
        flash[:notice] = "Sent #{visit_results.original_filename}"
      else
        send_failure = "Could not send PDF: #{result}"
        Rails.logger.error(send_failure)
        Sentry.capture_message(send_failure)
        flash[:alert] = send_failure
      end

      redirect_to admin_appointment_path(@appointment)
    end

    def update
      redirect_path = requested_redirect_path || admin_appointment_path(@appointment)
      if @appointment.update(appointment_params)
        redirect_to redirect_path, notice: "Appointment Updated"
      else
        redirect_to redirect_path, alert: [@appointment.errors.full_messages].flatten
      end
    end

    def create
      if @appointment.save
        redirect_to admin_appointment_path(@appointment), notice: "Appointment Created"
      else
        flash[:alert] = [@appointment.errors.full_messages].flatten
        redirect_to admin_appointments_path
      end
    end

    def render_visit_summary_pdf
      respond_to do |format|
        format.html
        format.pdf do
          pdf = VisitSummaryPdfExport.new(@appointment)
          send_data pdf.render,
                    filename:    "visit_summary.pdf",
                    type:        "application/pdf",
                    disposition: "inline"
          return true
        end
      end
      false
    end

    private

    def safe_appointment_params
      field_provider_id = params.to_unsafe_h.dig("appointment", "field_provider_id")
      if field_provider_id.present? && field_provider_id.is_a?(Array)
        params["appointment"]["field_provider_id"] =
          field_provider_id.first
      end

      # TODO: This should be fixed by making sure MedComboBox sends back an empty value in an array
      # when there are no items selected.
      params["appointment"]["tag_list"] = [] if params["appointment"]["tag_list"] == ""

      params
    end

    def set_appointment
      @appointment = Appointment.includes({admin_notes: :creator}, {tags: :versions}, :covid_vaccination).find(params[:id])
    end

    def appointment_params
      covid_vaccination_params = %i[reaction reaction_notes vaccine_type]
      extra_vaccine_recipients_params = %i[id name date_of_birth phone_number consent_to_text confirmed complete
                                           deleted]
      address_params = %i[id address_line_one address_line_two city state zipcode latitude longitude]
      patient_params = %i[id]
      safe_appointment_params.require(:appointment).permit(
        :status,
        :start_time,
        :end_time,
        :dispatch_notes,
        :state,
        :patient_id,
        :base_duration,
        :field_provider_id,
        :visit_results,
        address_attributes:                  address_params,
        patient_attributes:                  patient_params,
        covid_vaccination_attributes:        covid_vaccination_params,
        extra_vaccine_recipients_attributes: extra_vaccine_recipients_params,
        tag_list:                            []
      )
    end

    def availible_appointment_tags
      Appointment.available_tags.map(&:name)
    end

    def admin_note_params
      params.require(:admin_note).permit(:content, :creator_id)
    end

    def filters
      %i[status demand_partner tag start end timezone]
    end

    def enable_session_filters?
      true
    end
  end
end
