# frozen_string_literal: true

module Routing
  class GetVisits < ::ApplicationService
    include Helpers
    def initialize(start_date, end_date, filter_canceled = true, patient: false, fp_filter_list: nil)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
      @start_date = start_date
      @end_date = end_date.end_of_day
      @filter_canceled = filter_canceled
      @appointments = []
      @filter_by_patient = patient
      @fp_filter_list = fp_filter_list
    end

    def call
      query = Visit.includes({patient: %i[address demand_partner tags custom_field_responses programs user]}, :field_provider, :admin_notes, :services, {visit_type: :services}, :program, :work_sessions)
                   .where(program: {active: true})
                   .where("start_time >= ?", @start_date)
                   .where("start_time <= ?", @end_date)

      query = query.where(field_provider: {external_id: @fp_filter_list}) if @fp_filter_list.present?

      query = query.where(canceled: false) if @filter_canceled

      query = query.where(patient_id: @filter_by_patient.id) if @filter_by_patient

      @visits = []

      query.all.each do |visit|
        # Do we still want this?
        # next if visit.field_provider.blank?

        @visits << format_visit(visit)
      end

      OpenStruct.new(success?: true, message: "Visits fetched.", payload: @visits)
    end

    def format_admin_note(note)
      {
        text:       note.content,
        creator:    note.creator&.full_name, # unused
        created_at: note.created_at
      }
    end

    def format_visit(visit)
      AlayacareApiVisit.new(
        id:                    visit.id,
        alayacare_visit_id:    nil,
        visit_id:              visit.external_id,
        fp_id:                 visit&.field_provider&.external_id,
        fp_name:               visit&.field_provider&.full_name,
        start_time:            visit.start_time,
        end_time:              visit.end_time,
        cx_start:              round_time_15(visit.start_time),
        cx_end:                round_time_15(visit.end_time),
        demand_partner_id:     visit.patient.demand_partner_id, # this is needed for graphql queries
        demand_partner:        visit.patient.demand_partner,
        patient:               visit.patient.to_builder(include_programs: true).attributes!,
        status:                visit.display_status,
        client_id:             visit.patient.medical_record_number,
        program:               visit.program.to_builder(include_demand_partner = false, include_services = false,
                                                        include_visit_types = false).attributes!,
        confirmed:             visit.confirmed,
        visit_group_id:        visit.visit_group_id,
        # Need to match format
        notes:                 visit.admin_notes.map {|note| format_admin_note(note) },
        cancelled:             visit.canceled,
        location:              visit.patient.lat_long,
        cancel_code:           visit.cancel_code&.code,
        # legacy MA visit fields
        local:                 true,
        visit_type:            visit.visit_type&.to_builder(include_services = false)&.attributes!,
        services:              visit.services.map {|s| s.to_builder.attributes! },
        arrival_window_start:  visit&.arrival_window_start,
        arrival_window_end:    visit&.arrival_window_end,
        clock_in:              visit.work_sessions.last&.clock_in,
        clock_out:             visit.work_sessions.last&.clock_out,
        resources:             visit.visit_resources.map {|s| s.to_builder.attributes! },
        # athena data
        athena_telehealth_url: visit&.athena_telehealth_url
      )
    end
  end
end
