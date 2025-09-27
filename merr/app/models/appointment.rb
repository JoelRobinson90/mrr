# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: appointments
#
#  id                :bigint           not null, primary key
#  base_duration     :integer          default(30)
#  block_end_time    :datetime
#  block_start_time  :datetime
#  dispatch_notes    :text
#  drive_time        :float
#  end_time          :datetime
#  issue_reason      :string
#  route_index       :integer
#  start_time        :datetime
#  status            :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cohort_id         :integer
#  field_provider_id :bigint           indexed
#  patient_id        :bigint           indexed
#
# Indexes
#
#  index_appointments_on_field_provider_id  (field_provider_id)
#  index_appointments_on_patient_id         (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
class Appointment < ApplicationRecord
  include RequiredPhysicalAddress
  include ChangeEventTracker

  include PgSearch::Model
  pg_search_scope :search, against: [:id], associated_against: {
    patient:        %i[
      first_name
      last_name
      medical_record_number
      date_of_birth
      phone_number
      secondary_phone_number
    ],
    field_provider: %i[
      first_name
      last_name
    ],
    address:        %i[
      city
      state
      address_line_one
      address_line_two
    ]
  }, using: {tsearch: {prefix: true}}

  acts_as_taggable_on :tags

  class << self
    def available_tags
      Tag.where(group: "Appointment")
    end
  end

  STATUSES_MAP = {
    created:             "Created",
    pending_acceptance:  "Pending Acceptance",
    awaiting_scheduling: "Awaiting Scheduling",
    alayacare:           "Alayacare",
    vacant:              "Vacant",
    assigned:            "Assigned",
    en_route:            "En Route",
    on_site:             "On Site",
    in_progress:         "In Progress",
    complete:            "Complete",
    issue:               "Issue",
    canceled:            "Canceled",
    archived:            "Archived"
  }.freeze

  STATUSES = [
    STATUSES_MAP[:created],
    STATUSES_MAP[:pending_acceptance],
    STATUSES_MAP[:awaiting_scheduling],
    STATUSES_MAP[:alayacare],
    STATUSES_MAP[:vacant],
    STATUSES_MAP[:assigned],
    STATUSES_MAP[:en_route],
    STATUSES_MAP[:on_site],
    STATUSES_MAP[:in_progress],
    STATUSES_MAP[:complete],
    STATUSES_MAP[:issue],
    STATUSES_MAP[:canceled],
    STATUSES_MAP[:archived]
    # "Care Plan Needed", # Toggle back when needed
  ].freeze

  ISSUES_STATUSES = [
    "Patient no show",
    "Patient refused vaccine",
    "Patient requested a reschedule",
    "Patient disqualified by intake questions",
    "Other"
  ].freeze

  belongs_to :field_provider, optional: true
  belongs_to :patient, optional: false
  has_one :order
  has_many :communication_logs, as: :context, dependent: :destroy
  has_many :extra_vaccine_recipients
  has_one :covid_vaccination, dependent: :destroy
  has_one :demand_partner, through: :patient
  has_many :surveys

  accepts_nested_attributes_for :extra_vaccine_recipients, allow_destroy: true

  accepts_nested_attributes_for :patient, allow_destroy: false


  has_many :admin_notes, as: :notable, dependent: :destroy

  validates :status,
            inclusion: {in: Appointment::STATUSES, message: "%{value} is not a valid appointment status"}
  validates :issue_reason, inclusion: {in: Appointment::ISSUES_STATUSES}, allow_blank: true

  validates :start_time, :end_time, presence: true, unless: lambda {
                                                              ["Created", "Pending Acceptance",
                                                               "Awaiting Scheduling", "Canceled",
                                                               "Archived"].include? status
                                                            }

  validates :base_duration, numericality: {greater_than_or_equal_to: 0, only_integer: true}

  accepts_nested_attributes_for :patient, :covid_vaccination, :address

  # Denormalize timezone since it's used a lot?
  delegate :timezone, to: :address, allow_nil: true

  # USE: these fields are used on the front end for triggering specific field provider flows.
  attr_accessor :extra_vaccine_recipient_selected, :should_complete

  # Returns surveys that are either:
  # - associated with the appointment, or
  # - associated with the patient, not completed, and have no appointment
  def available_surveys
    surveys.or(patient.surveys.not_responded.where(appointment_id: nil))
  end

  # Paper trail story association
  def trailed_related_content
    tags | [field_provider] | [patient] | [address]
  end

  def vaccine_quantity
    extra_vaccine_recipients.select(&:confirmed?).length + 1
  end

  def vaccines_delivered
    extra_vaccine_recipients.select(&:complete?).length + (status == "Issue" ? 0 : 1)
  end

  def duration
    return nil if base_duration.blank?

    duration = base_duration
    # 15 min for every two extra recipients
    duration += (extra_vaccine_recipients.select(&:confirmed?).length / 2.0).ceil * 15
    # 15 min for HRA survey
    duration += 15 if patient.hra_survey_status == "Pending"
    duration
  end

  def all_tags
    tag_list.join(", ")
  end

  # Returns list of statuses a field provider should checkin (mark as On Route or On Site)
  def field_provider_check_in_allowed
    Appointment::STATUSES[0..6]
  end

  def status_trail_for(status_name)
    status_trail = versions.includes(:item).order(created_at: :DESC).select do |v|
                     v.changeset.dig("status", 1) == status_name
                   end&.first
    return unless status_trail

    {
      name:       status_name,
      created_at: status_trail.created_at
    }
  end

  def to_s
    patient.display_name
  end

  def to_builder(include_admin_notes: false,
                 include_extra_vaccine_recipients: false,
                 include_hra_survey: false,
                 include_order: false,
                 include_available_surveys: false)
    Jbuilder.new do |appointment|
      appointment.call(self, :id, :status, :start_time, :end_time, :issue_reason, :block_start_time, :block_end_time,
                       :tag_list, :dispatch_notes, :updated_at, :created_at, :base_duration, :patient_id)
      appointment.patient patient.to_builder if patient
      appointment.address address.to_builder if address
      appointment.field_provider field_provider.to_builder if field_provider
      appointment.admin_notes(admin_notes.map {|admin_note| admin_note.to_builder.attributes! }) if include_admin_notes
      appointment.covid_vaccination covid_vaccination.to_builder if covid_vaccination

      if include_extra_vaccine_recipients
        appointment.extra_vaccine_recipients(extra_vaccine_recipients.map {|evr| evr.to_builder.attributes! })
        appointment.confirmed_extra_vaccine_recipients(extra_vaccine_recipients.where(confirmed: true).map do |evr|
                                                         evr.to_builder.attributes!
                                                       end)
        appointment.duration duration if include_hra_survey
      end
      appointment.hra_survey_status patient.hra_survey_status if include_hra_survey
      appointment.order order.to_builder.attributes! if include_order && order.present?
      appointment.available_surveys available_surveys.map(&:to_builder).map(&:attributes!) if include_available_surveys
    end
  end
end
