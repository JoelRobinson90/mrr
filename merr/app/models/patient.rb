# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: patients
#
#  id                             :bigint           not null, primary key
#  consent_to_email               :boolean          default(FALSE), not null
#  consent_to_text                :boolean          default(FALSE), not null
#  contact_email                  :string
#  date_of_birth                  :date
#  emergency_contact_name         :string
#  emergency_contact_phone_number :string
#  ethnicity                      :string
#  first_name                     :string
#  gender                         :string
#  last_name                      :string
#  medical_record_number          :string
#  middle_initial                 :string
#  needs_hra_survey               :boolean
#  patient_notes                  :text
#  phone_number                   :string
#  phone_number_type              :string
#  preferred_contact_method       :string
#  preferred_language             :string
#  preferred_pronouns             :string
#  primary_risk_category          :string
#  push_to_athena_error           :string
#  race                           :string
#  region                         :string
#  secondary_phone_number         :string
#  secondary_phone_number_type    :string
#  sex                            :string
#  status                         :string           default("Created"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  athena_id                      :integer
#  datalake_id                    :string
#  demand_partner_id              :bigint           not null, indexed
#  external_id                    :string           not null, indexed
#  ma_id                          :string           indexed
#  primary_care_physician_id      :bigint           indexed
#
# Indexes
#
#  index_patients_on_demand_partner_id          (demand_partner_id)
#  index_patients_on_external_id                (external_id) UNIQUE
#  index_patients_on_ma_id                      (ma_id)
#  index_patients_on_primary_care_physician_id  (primary_care_physician_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#  fk_rails_...  (primary_care_physician_id => primary_care_physicians.id)
#
require "#{Rails.root}/lib/language_code_to_name"

class Patient < ApplicationRecord
  include FormattedPhoneNumber
  include OptionalPhysicalAddress
  include PatientConstants

  include PgSearch::Model
  pg_search_scope :search, against: %i[
    first_name
    middle_initial
    last_name
    date_of_birth
    medical_record_number
    phone_number
  ], using: {tsearch: {prefix: true}},
    associated_against: {
      address: %i[address_line_one address_line_two city state]
    }
  pg_search_scope :external_users_search, against: %i[
    first_name
    middle_initial
    last_name
    date_of_birth
    medical_record_number
    phone_number
  ], using: {tsearch: {prefix: true}} # ,    *LJA remove this comment if we want to search city and state. Doing so should negatively impact performance.
  # associated_against: {
  #  address: %i[city state]
  # }

  validates :medical_record_number, uniqueness: {on: :create, scope: [:demand_partner]}
  validates :medical_record_number, presence: true, on: :create

  include UserAccount
  include ExternalId
  include PushToExternal
  include PushToSalesforce

  delegate :address_line_one, :address_line_two, :city, :state, :zipcode, :latitude, :longitude, :timezone,
           to: :address, allow_nil: true
  delegate :notes, to: :address, allow_nil: true, prefix: true

  belongs_to :demand_partner
  belongs_to :primary_care_physician, optional: true

  has_many :appointments, dependent: :destroy
  has_many :insurances, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :pharmacies, dependent: :destroy
  has_many :patient_programs, dependent: :destroy, inverse_of: :patient
  has_many :custom_field_responses, dependent: :destroy
  has_one :latest_order, -> { order(created_at: :desc) }, class_name: "Order"
  has_many :service_requests, dependent: :destroy
  has_many :insurance_policies, -> { order(created_at: :desc) }
  has_one :latest_insurance_policy, -> { order(created_at: :desc) }, class_name: "InsurancePolicy"

  has_many :admin_notes, as: :notable, dependent: :destroy

  has_one :hra_survey, dependent: :destroy
  has_many :surveys

  has_many :visits
  has_many :programs, through: :patient_programs
  has_many :service_requests

  has_many :provider_preferences
  has_many :preferred_providers, through: :provider_preferences, source: :field_provider

  has_one :patient_geo
  has_one :service_area, through: :patient_geo
  has_one :geo_cohort, through: :patient_geo

  attr_accessor :update_alayacare_in_foreground, :ehr_custom_import_attributes, :custom_field_responses_attributes,
                :patient_programs_attributes, :skip_push_to_alayacare

  acts_as_taggable_on :tags

  accepts_nested_attributes_for :pharmacies, allow_destroy: true
  accepts_nested_attributes_for :custom_field_responses, allow_destroy: true
  accepts_nested_attributes_for :insurances, allow_destroy: true

  before_save :format_region

  validates :sex, inclusion: {in:      SEXES,
                              message: "'%{value}' is not a recognized sex"}, allow_nil: true

  validates :preferred_language, inclusion: {in: LANGUAGES, allow_blank: true,
                                             message: "'%{value}' is not a recognized language"}, allow_nil: true
  validates :race, inclusion: {in: RACES, allow_blank: true,
                               message: "'%{value}' is not a recognized race"}, allow_nil: true
  validates :ethnicity, inclusion: {in: ETHNICITY, allow_blank: true,
                                    message: "'%{value}' is not a recognized ethnicity"}, allow_nil: true
  validates :gender, inclusion: {in: GENDERS, allow_blank: true,
                                    message: "'%{value}' is not a recognized gender"}, allow_nil: true
  validates :preferred_pronouns, inclusion: {in: PREFERRED_PRONOUNS, allow_blank: true,
                                    message: "'%{value}' is not a recognized pronoun"}, allow_nil: true

  validates :phone_number_type, inclusion: {in: PHONE_TYPES, allow_blank: true,
                                      message: "'%{value}' is not a recognized phone types"}, allow_nil: true
  validates :secondary_phone_number_type, inclusion: {in: PHONE_TYPES, allow_blank: true,
                                      message: "'%{value}' is not a recognized phone types"}, allow_nil: true

  # Only one will actually execute based on "update_alayacare_in_foreground" flag
  before_save :update_alayacare_client
  after_save :update_alayacare_client_async

  def self.text_search(query:, external: false)
    query = "+1#{query}" if query.match(/^[0-9]{10}$/)

    if external
      external_users_search(query)
    else
      search(query)
    end
  end

  def should_update_alayacare?
    return false if skip_push_to_alayacare
    
    eligible_programs = self.programs.filter do |program|
      !program.v2 && program.active
    end

    eligible_programs.length.positive?
  end

  def update_alayacare_client
    return unless update_alayacare_in_foreground

    return unless should_update_alayacare?

    result = Alayacare::ClientCreateOrUpdateService.call(self, ["all"])
    unless result.success?
      msg = "Updating Alayacare patient failed: "
      msg += result.respond_to?(:code) ? "#{result.code} - #{result.body}" : result.error.to_s
      errors.add(:base, msg)
      Sentry.capture_message(msg)
      Rails.logger.error(msg)
      throw :abort
    end
  end

  def update_alayacare_client_async
    return if update_alayacare_in_foreground

    return unless should_update_alayacare?

    CreateOrUpdateAlayacareClientJob.perform_later(self)
  end

  def push_to_athena(mode)
    return OpenStruct.new(success?: true) unless self.athena_id.present?
    
    Athena::PushPatient.call(self, nil)
  end

  def format_region
    self.region = region.strip if region.present?
  end

  class << self
    def available_tags
      Tag.where(group: "Patient")
    end
  end

  def full_name
    [first_name, middle_initial, last_name].compact.join(" ")
  end

  def to_s
    full_name
  end

  def preferred_providers_one_per_role
    providers_by_role = {}

    # only return most recent preference for each role
    self.provider_preferences.includes(:field_provider).order(created_at: :asc).each do |pref|
      providers_by_role[pref.field_provider.role] = pref.field_provider
    end

    return providers_by_role.values
  end

  def visit_services
    visits.includes(:visit_services).flat_map(&:visit_services)
  end

  # Paper trail story association
  def trailed_related_content
    [address] | visits | [patient_geo] | insurance_policies
  end

  # WARNING: edit frontend types if changing these strings.
  def hra_survey_status
    # check if we are responsible for the survey
    return "Not Required" unless needs_hra_survey

    # check if we have given the survey
    hra_survey.present? ? "Complete" : "Pending"
  end

  def display_secondary_phone_number
    Utility.display_phone(secondary_phone_number) if secondary_phone_number
  end

  def programs_string
    programs.map(&:name).join(", ")
  end

  def to_builder(
    include_admin_notes: false,
    include_insurances: false,
    include_pharmacies: false,
    include_clinical_summary: false,
    include_latest_order: false,
    include_primary_care_physician: false,
    include_custom_field_responses: false,
    include_programs: false
  )
    Jbuilder.new do |patient|
      patient.call(self,
                   :id,
                   :status,
                   :date_of_birth,
                   :emergency_contact_name,
                   :first_name,
                   :middle_initial,
                   :last_name,
                   :medical_record_number,
                   :phone_number,
                   :phone_number_type,
                   :display_phone_number,
                   :display_secondary_phone_number,
                   :preferred_pronouns,
                   :secondary_phone_number,
                   :secondary_phone_number_type,
                   :consent_to_text,
                   :sex,
                   :preferred_language,
                   :race,
                   :ethnicity,
                   :needs_hra_survey,
                   :gender,
                   :tags,
                   :primary_risk_category,
                   :consent_to_email,
                   :preferred_contact_method,
                   :contact_email)

      patient.address address.to_builder if address

      if custom_field_responses
        patient.custom_field_responses(custom_field_responses.map do |custom_field_response|
                                         custom_field_response.to_builder.attributes!
                                       end)
      end

      if include_programs
        patient.programs programs.map {|p|
                           p.to_builder(include_demand_partner = false, include_services = false,
                                        include_visit_types = false).attributes!
                         }
      end
      patient.admin_notes(admin_notes.map {|admin_note| admin_note.to_builder.attributes! }) if include_admin_notes
      patient.user user.to_builder if user
      patient.demand_partner demand_partner.to_builder if demand_partner

      patient.insurances insurances if include_insurances

      patient.pharmacies pharmacies if include_pharmacies

      patient.latest_order latest_order&.to_builder&.attributes! if include_latest_order

      patient.primary_care_physician primary_care_physician&.to_builder&.attributes! if include_primary_care_physician
    end
  end

  def should_push_to_salesforce?
    programs.any?(&:v2?)
  end

  def to_ma_object
    fields = %i[ma_id medical_record_number first_name last_name phone_number date_of_birth gender
             contact_email address_line_one address_line_two city state zipcode latitude longitude
             timezone address_notes preferred_language]
    make_ma_object(fields, [:demand_partner])
  end
end
