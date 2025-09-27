# typed: true
# frozen_string_literal: true

class Ability
  include CanCan::Ability
  ROLES = {
    FieldAdmin:                 FieldAdmin,
    FieldDispatcher:            FieldDispatcher,
    FieldProvider:              FieldProvider,
    MedarriveAdmin:             MedarriveAdmin,
    MedarriveClinicalOperation: MedarriveClinicalOperation,
    MedarriveCustomerSupport:   MedarriveCustomerSupport,
    ExternalAccount:            ExternalAccount
  }.freeze

  attr_reader :user

  delegate :account, :account_id, to: :user
  delegate :field_org_id, to: :account

  def initialize(user_arg = nil)
    @user = user_arg || User.new

    authorize_super_admin and return if user.is_super_admin?
    authorize_medarrive_admin and return if user.medarrive_admin?
    authorize_medarrive_customer_support and return if user.is_medarrive_customer_support?
    authorize_medarrive_clinical_operations and return if user.is_medarrive_clinical_operations?

    # :down: These two are intermixed and need to be cleaned up :down:
    # these are required to be in this order to function as expected
    authorize_field_user and return if user.is_field_account?
    authorize_field_admin and return if user.is_field_admin?
    # :up: These two are intermixed and need to be cleaned up :up:
    #
    authorize_coordinator and return if user.is_demand_coordinator?

    authorize_external_account and return if user.is_external_account?

    authorize_non_user
  end

  private

  def administrate
    # TODO: Temporarily broaden permissions to avoid blocking ops.  Clean up soon.
    return :manage

    # Specificity of permissions
    %i[create update read]
  end

  def authorize_super_admin
    # TODO: we want to get rid of this and explicitly add super_admin privileges over medarive admins
    can_use_rails_admin
    authorize_medarrive_admin
  end

  def authorize_medarrive_admin
    can administrate, User, account_type: "MedarriveAdmin"
    can %i[invite_users], FieldOrg
    can %i[visit_results], Appointment

    can administrate, [
      AlayacareApiVisit,
      AvailabilitySlot,
      DemandPartner,
      ExternalAccount,
      FieldAdmin,
      FieldDispatcher,
      FieldOrg,
      FieldProvider,
      MedarriveAdmin,
      OutreachCampaign,
      PatientProspect,
      SchedulerLog,
      Service,
      ServiceRequest,
      Tag,
      VisitRequest,
      Visit,
      VisitType,
    ]

    # TBD: Can manage additional Service/services once we implement them

    can_administrate_patient_nonhealth_data
    can_administrate_patient_health_data

    can administrate, :availability

    can :delete, [PatientProspect]

    can %i[read create], AdminNote
    can %i[read create], HraSurvey
    can %i[read respond], Survey
  end

  def authorize_medarrive_customer_support
    # customer support can update their own notes.
    can :create, AdminNote

    can :administrate, SchedulerLog

    # They can read an AdminNote if they have access to the notated record.
    # (Org-level)
    can :read, AdminNote
    can :read, Service
    can :read, VisitType
    can :read, Program

    can %i[read create], Tag

    can_administrate_patient_nonhealth_data
    can_administrate_patient_health_data
  end

  def authorize_medarrive_clinical_operations
    # clinical operations can update their own notes.
    can :create, AdminNote

    # They can read an AdminNote if they have access to the notated record.
    # (Org-level)
    can :read, AdminNote
    can :read, Service
    can :read, VisitType

    can %i[read create], Tag

    can_administrate_patient_nonhealth_data
    can_administrate_patient_health_data
  end

  def authorize_field_user
    # All field accounts
    can :read, FieldOrg, id: field_org_id
    can :read, [FieldAdmin, FieldDispatcher, FieldProvider],
        field_org_id: field_org_id

    can :show, PrimaryCarePhysician
    can :read, Service
    can :read, VisitType
    can %i[read show], Patient
    can %i[read create], HraSurvey
    can %i[read respond], Survey
    can %i[read update], ExtraVaccineRecipient

    authorize_field_admin and return if user.is_field_admin?
    authorize_field_dispatcher and return if user.is_field_dispatcher?

    authorize_field_provider if user.is_field_provider?
  end

  def authorize_field_admin
    # Field accounts can update their own notes.
    can :create, AdminNote

    # They can read an AdminNote if they have access to the notated record.
    # (Org-level)
    can :read, AdminNote

    can :update, AdminNote, creator_id: user.id

    can :read, :availability
    can administrate, Tag

    can administrate, FieldOrg, id: field_org_id
    can administrate, [FieldAdmin, FieldDispatcher, FieldProvider],
        field_org_id: field_org_id
  end

  def authorize_field_dispatcher
    can :read, FieldAdmin, field_org_id: field_org_id

    # Field Dispatcher users
    can %i[create update], [FieldDispatcher, FieldProvider],
        field_org_id: field_org_id
  end

  def authorize_field_provider
    # Field Providers can manage their own accounts, certifications, and training.
    can administrate, FieldProvider, id: account_id
    can administrate, Patient
    can :read, PrimaryCarePhysician

    # TODO: restrict appointment view by appointment state?
    can administrate, Appointment, field_provider_id: account_id
    # @TODO: revisit this permissions later
    can administrate, AdminNote, creator_id: user.id
    can administrate, Visit

    can :create, HraSurvey
    can %i[read respond], Survey
  end

  def authorize_external_account
    can :show, PrimaryCarePhysician
    can :read, Service
    can :read, VisitType
    can :read, Program, id: account.program_ids
    can %i[read update], ExtraVaccineRecipient

    can administrate, ExternalAccount, id: account_id
    can administrate, Patient, patient_programs: {program_id: account.program_ids}
    can :read, PrimaryCarePhysician

    can administrate, Visit, program_id: account.program_ids
  end

  def authorize_coordinator
    can :read, :availability
    can :read, Patient, demand_partner_id: account.try(&:demand_partner_id)
    can :create, Patient, demand_partner_id: account.try(&:demand_partner_id)
    can :create, PatientProspect, demand_partner_id: account.try(&:demand_partner_id)
    can :read, AlayacareApiVisit, demand_partner_id: account.try(&:demand_partner_id)
    can %i[read create], VisitRequest, program: {demand_partner_id: account.try(&:demand_partner_id)}
  end

  def authorize_non_user
    # User is not logged in or has no account somehow
  end

  def can_administrate_patient_nonhealth_data
    can administrate, Address, addressable_type: "Patient"
    can administrate, Patient
  end

  def can_administrate_patient_health_data
    can administrate, [
      Appointment,
      HraSurvey,
      Survey,
      Insurance,
      Order,
      Pharmacy,
      CustomFieldResponse,
      PrimaryCarePhysician,
      Visit,
      ServiceRequest
    ]

    can administrate, Address, addressable_type: %w[Pharmacy Appointment Patient]
  end

  # TODO: this is currently being superseeded, and is a stub for future updates
  def can_use_rails_admin
    can :access, :rails_admin   # grant access to rails_admin
    can :read, :dashboard       # grant access to the rails_admin dashboard

    # things only accessed through rails_admin:

    can administrate, Address
    can administrate, AdminNote
    can administrate, Appointment
    can administrate, AlayacareServiceCode
    can administrate, AthenaCustomField
    can administrate, AthenaDepartment
    can administrate, AvailabilitySlot
    can administrate, CommunicationLog
    can administrate, CovidVaccination
    can administrate, CustomFieldResponse
    can administrate, Delayed::Backend::ActiveRecord::Job
    can administrate, DemandCoordinator
    can administrate, DemandPartner
    can administrate, DemandPartnerCustomField
    can administrate, ExternalAccount
    can administrate, ExtraVaccineRecipient
    can administrate, FieldAdmin
    can administrate, FieldDispatcher
    can administrate, FieldOrg
    can administrate, FieldProvider
    can administrate, HraSurvey
    can administrate, Survey
    can administrate, Insurance
    can administrate, InsurancePolicy
    can administrate, MedarriveAdmin
    can administrate, MedarriveClinicalOperation
    can administrate, MedarriveCustomerSupport
    can administrate, Order
    can administrate, Patient
    can administrate, PatientProspect
    can administrate, Pharmacy
    can administrate, PrimaryCarePhysician
    can administrate, ProviderPreference
    can administrate, SmsTemplate
    can administrate, Tag
    can administrate, User
    can administrate, Program
    can administrate, Visit
    can administrate, CancelCode
    can administrate, Service
    can administrate, VisitType
    can administrate, VisitEvent
    can administrate, SchedulerLog
    can administrate, WorkSession
    can administrate, ServiceArea
    can administrate, GeoCohort
    can administrate, PatientGeo
    can administrate, VisitResourceRequirement
    can administrate, VisitResource
  end

  def self.lookup_role(role)
    Ability::ROLES.fetch(role.to_sym)
  rescue KeyError => e
    raise "Role #{role} does not exist"
  end
end
