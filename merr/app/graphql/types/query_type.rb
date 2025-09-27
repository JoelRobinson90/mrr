# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    # include GraphQL::Types::Relay::HasNodeField
    # include GraphQL::Types::Relay::HasNodesField

    include Queries::PatientQueries
    include Queries::AlayacareVisitQueries
    include Queries::VisitRequestQueries
    include Queries::OutreachCampaignQueries
    include Queries::VisitQueries
    include Queries::SchedulerQueries
    include Queries::CancelCodeQueries
    include Queries::VisitNoteQueries
    include Queries::ProgramQueries

    field :get_visit_notes, [AdminNoteType], "Find visit notes" do
      argument :notable_id, Int, required: false
    end

    field :get_current_user, UserType, "Get current user"

    field :get_patient, PatientType, "Find a patient by ID or MA ID" do
      argument :id, ID, required: false
      argument :ma_id, ID, required: false
    end

    field :get_patients, [PatientType], "Find patients", extras: [:lookahead] do
      argument :page, Int, required: false, default_value: 1
      argument :per_page, Int, required: false, default_value: 100
      argument :ids, [ID], required: false, default_value: nil
      argument :search, String, required: false, default_value: ""
      argument :program_id, String, required: false, default_value: ""
    end

    field :get_program, ProgramType, "Find program" do
      argument :id, ID, required: false
      argument :ma_id, ID, required: false
    end

    field :get_alayacare_visits, [AlayacareVisitType], "Find visits" do
      argument :date, String
      argument :demand_partner_id, ID, required: false
    end

    field :get_visit_requests, [VisitRequestType], "Find visit requests", extras: [:lookahead] do
      argument :pending, Boolean, required: false
    end

    field :get_app_constants, AppConstantsType, "Get app constants"

    field :outreach_campaigns, [OutreachCampaignType], "Get outreach campaigns" do
      argument :active, Boolean, required: false
    end

    field :get_visit, VisitType, "Find a visit by Alayacare external ID", extras: [:lookahead] do
      argument :alayacare_visit_id, Int, required: false
      argument :ma_id, ID, required: false
      argument :id, ID, required: false
      argument :external_id, ID, required: false
      argument :include_notes, Boolean, required: false
    end

    field :get_scheduler_data, SchedulerDataType, "Get Scheduler metadata" do
      argument :patient_id, ID, required: false
      argument :program_id, String, required: false
      argument :service_code_id, String, required: false
      argument :start_date, String, required: false
      argument :end_date, String, required: false
      argument :top_suggestions, String, required: false
      argument :duration, String, required: false
      argument :limit_arrival_times, String, required: false
      argument :external_id, String, required: false
      argument :existing_visit_alayacare_id, String, required: false
      argument :visit_type_id, String, required: false
      argument :ignore_existing_visit_conflicts, Boolean, required: false
    end

    field :get_preferred_providers, [PreferredProviderType], "Get preferred providers for a patient" do
      argument :patient_id, ID, required: true
    end

    field :get_visits, [VisitType], "Fetch current user visits" do
      argument :start_time, String, required: false
      argument :end_time, String, required: false
      argument :limit, Integer, required: false
    end

    field :get_cancel_codes, [CancelCodeType], "Get cancel codes (only v2 codes with athena_id populated)"

    def get_app_constants
      AppConstants.new
    end

    def get_current_user
      current_user
    end

    private

    def authorized?(*args)
      current_ability.can?(*args)
    end

    def current_user
      context[:current_user]
    end

    def current_ability
      context[:current_ability]
    end
  end
end
