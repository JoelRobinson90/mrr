# frozen_string_literal: true

# typed: true
require "nested_form/engine"
require "nested_form/builder_mixin"

RailsAdmin.config do |config|
  config.main_app_name = proc {|_controller|
    ["MedArrive", "Admin", EnvHelper.env_or_nil("HOST_ENV") || Rails.env]
  }

  ### Popular gems integration

  ## == Devise ==
  #
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == CancanCan ==
  config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  config.audit_with :paper_trail, "User", "PaperTrail::Version" # PaperTrail >= 3.0.0
  PAPER_TRAIL_AUDIT_MODEL = ['Visit', 'Patient', 'FieldProvider', 'Program']

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.label_methods.concat(%i[full_name display_name])

  config.actions do
    # root actions
    dashboard # mandatory

    # collection actions
    index # mandatory
    new
    export

    # member actions
    show
    edit
    show_in_app

    delete do
      only %w[AvailabilitySlot DemandPartnerCustomField Program VisitType Service ServiceArea GeoCohort PatientGeo]
    end

    ## With an audit adapter, you can add:
    # history_index do
    #   only []
    # end
    # history_show do
    #   only PAPER_TRAIL_AUDIT_MODEL
    # end
  end

  config.model "HraSurvey" do
    list do
      exclude_fields :survey
    end
  end

  config.model "FieldProvider" do
    exclude_fields :admin_notes

    create do
      exclude_fields :visits, :appointments, :work_sessions
    end
  end

  config.model "DemandPartnerCustomField" do
    exclude_fields :patients, :programs, :appointments, :visits

    list do
      include_fields :demand_partner, :csv_column_name, :crm_field_name, :ehr_field_name, :data_type
    end
  end

  config.model "SchedulerLog" do
    list do
      include_fields :user, :request_time, :patient, :disposition, :index_chosen, :options_count, :run_id
    end
  end

  config.model "Visit" do
    exclude_fields :visit_services, :versions

    object_label_method do
      :external_id
    end

    show do
      field :covered_service_requests do
        read_only true
        pretty_value do
          bindings[:object].covered_service_requests.map do |sr|
            path = bindings[:view].show_url(model_name: "ServiceRequest", id: sr.id)
            "<a href=#{path}>#{sr}</a>"
          end.join(", ").html_safe
        end
      end
    end
  end

  config.model "VisitType" do
    exclude_fields :visit_type_services, :program_visit_types
  end

  config.model "Program" do
    exclude_fields :program_services, :patient_programs, :program_visit_types, :patients, :visits,
                   :ext_acct_programs, :patient_geos, :geo_cohorts, :service_areas
  end

  config.model "Patient" do
    exclude_fields :patient_programs, :patient_geos

    list do
      field :programs do
        searchable [{Program => :name}]
      end
    end
  end

  config.model "Appointment" do
    list do
      configure :all_tags do
        formatted_value do
          value
        end
      end
      include_fields :all_tags, :id, :status, :start_time, :end_time, :field_provider_id, :created_at, :updated_at,
                     :block_start_time, :block_end_time, :patient_id, :route_index, :issue_reason, :dispatch_notes, :base_duration, :drive_time,
                     :demand_partner, :patient, :field_provider, :order, :extra_vaccine_recipients, :covid_vaccination,
                     :admin_notes, :address, :communication_logs
    end

    export do
      configure :all_tags do
        formatted_value do
          value
        end
      end

      field :all_tags do
        label "Tag List"
      end
      include_fields :all_tags, :id, :status, :start_time, :end_time, :field_provider_id, :created_at, :updated_at,
                     :block_start_time, :block_end_time, :patient_id, :route_index, :issue_reason, :dispatch_notes, :base_duration, :drive_time,
                     :demand_partner, :patient, :field_provider, :order, :extra_vaccine_recipients, :covid_vaccination,
                     :admin_notes, :address, :communication_logs
    end
  end

  config.model "OutreachCampaign" do
    exclude_fields :contacts
  end

  config.model "User" do
    edit do
      exclude_fields :admin_notes
    end

    object_label_method do
      :email
    end
  end

  # Disable versions for all objects
  # Needs to be at the end or it messes up ordering
  %w[Address AdminNote AlayacareServiceCode Appointment AthenaCustomField AthenaDepartment AvailabilitySlot CancelCode
     CommunicationLog CustomFieldResponse DemandCoordinator DemandPartner DemandPartnerCustomField
     ExternalAccount FieldAdmin FieldDispatcher FieldOrg FieldProvider GeoCohort
     Insurance MedarriveAdmin MedarriveClinicalOperation MedarriveCustomerSupport Order
     OutreachCampaign Patient PatientGeo PatientProspect Pharmacy PrimaryCarePhysician ProviderPreference Program
     SchedulerLog Service ServiceArea SmsTemplate Survey Tag User Visit VisitEvent VisitResource
     VisitResourceRequirement VisitRequest VisitType WorkSession ].each do |klass|
    config.model klass do
      exclude_fields :versions, :appointments

      edit do
        exclude_fields :versions, :appointments
      end

      show do
        field :papertrail_link do
          formatted_value do
            "<a href=\"/papertrail/#{bindings[:object].class.name}/#{bindings[:object].id}\">History</a>".html_safe
          end
        end
      end
    end
  end
end
