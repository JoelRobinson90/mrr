# frozen_string_literal: true

# == Schema Information
#
# Table name: visits
#
#  id                       :bigint           not null, primary key
#  alayacare_status         :string
#  arrival_window_end       :datetime
#  arrival_window_start     :datetime
#  athena_telehealth_url    :string
#  canceled                 :boolean          default(FALSE)
#  confirmed                :boolean          default(FALSE)
#  end_time                 :datetime         not null
#  last_athena_sync         :string
#  push_to_alayacare_error  :string
#  push_to_athena_error     :string
#  reschedule_count         :integer
#  service_instructions     :string
#  start_time               :datetime         not null
#  status                   :string           default("scheduled")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  athena_encounter_id      :integer
#  athena_id                :integer
#  cancel_code_id           :bigint           indexed
#  external_id              :string           not null, indexed
#  field_provider_id        :bigint           indexed
#  ma_id                    :string           indexed
#  next_linked_visit_id     :integer
#  original_visit_id        :integer
#  patient_id               :bigint           not null, indexed
#  previous_linked_visit_id :integer
#  program_id               :bigint           not null, indexed
#  visit_group_id           :integer
#  visit_request_id         :bigint           indexed
#  visit_type_id            :bigint           not null, indexed
#
# Indexes
#
#  index_visits_on_cancel_code_id     (cancel_code_id)
#  index_visits_on_external_id        (external_id) UNIQUE
#  index_visits_on_field_provider_id  (field_provider_id)
#  index_visits_on_ma_id              (ma_id)
#  index_visits_on_patient_id         (patient_id)
#  index_visits_on_program_id         (program_id)
#  index_visits_on_visit_request_id   (visit_request_id)
#  index_visits_on_visit_type_id      (visit_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (cancel_code_id => cancel_codes.id)
#  fk_rails_...  (field_provider_id => field_providers.id)
#  fk_rails_...  (next_linked_visit_id => visits.id)
#  fk_rails_...  (original_visit_id => visits.id)
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (previous_linked_visit_id => visits.id)
#  fk_rails_...  (program_id => programs.id)
#  fk_rails_...  (visit_request_id => visit_requests.id)
#  fk_rails_...  (visit_type_id => visit_types.id)
#
class Visit < ApplicationRecord
  include ExternalId
  include PushToExternal
  include PushToSalesforce
  include Routing::Helpers

  belongs_to :patient, optional: false
  belongs_to :visit_type, optional: false
  belongs_to :field_provider, optional: true
  belongs_to :visit_group, optional: true
  belongs_to :program, optional: false
  belongs_to :cancel_code, optional: true
  has_many :visit_services, dependent: :destroy, after_add: :set_services_changed_flag,
after_remove: :set_services_changed_flag
  has_many :admin_notes, as: :notable, dependent: :destroy
  has_many :services, through: :visit_services
  has_many :work_sessions, dependent: :nullify
  has_many :visit_events, dependent: :nullify
  belongs_to :visit_request, optional: true
  has_one :scheduler_log, dependent: :nullify
  belongs_to :original_visit, class_name: "Visit", optional: true
  belongs_to :next_linked_visit, class_name: "Visit", optional: true
  belongs_to :previous_linked_visit, class_name: "Visit", optional: true
  has_many :visit_resources, dependent: :destroy
  accepts_nested_attributes_for :visit_resources
  has_many :providers, through: :visit_resources, source: "field_provider"

  has_one :address, through: :patient

  validates :start_time, presence: true
  validates :end_time, presence: true

  validates :cancel_code, presence: true, if: :canceled?

  # validates :status, inclusion: {in: %w[scheduled en_route clocked completed]}

  before_save :update_arrival_window
  before_save :update_status_on_cancel
  after_create :send_confirmation
  before_update :udpate_reschedule_count, if: :saved_change_to_start_time?
  before_update :reset_confirmed, if: :reset_confirmed_needed?
  after_update :send_confirmation, if: :confirmation_needed?
  after_save :on_check_in
  after_save :update_service_requests

  attr_accessor :services_modified, :notes

  # Automatic callback, but only works for adding or removing one service at a time.
  def set_services_changed_flag(_service)
    self.services_modified = true
  end

  def covered_service_requests
    ServiceRequest.where(patient: patient_id, program: program_id, service: services)
  end

  def update_service_requests
    covered_service_requests.each(&:refresh_status)
  end

  # Used in the controller when bulk assigning services.
  def check_for_changed_services(new_services)
    new_service_ids = new_services.map(&:to_s).sort
    old_service_ids = services.pluck(:id).map(&:to_s).sort
    self.services_modified = true unless new_service_ids == old_service_ids
  end

  def push_to_alayacare(mode)
    Alayacare::PushVisit.call(mode, self)
  end

  def push_to_athena(mode)
    Athena::PushVisit.call(mode, self)
  end

  def push_to_athena_validation
    Athena::ValidateVisit.call(self)
  end

  def on_check_in
    return unless saved_change_to_status? &&
                  %w[clocked clocked_in].include?(status)

    Athena::InitiateVisitCheckIn.call(self)
  end

  def mark_canceled(cancel_code_id)
    self.canceled = true
    self.cancel_code_id = cancel_code_id
    self.alayacare_status = "cancelled"
    self.visit_group_id = nil
  end

  def to_s
    external_id
  end

  def cx_start
    round_time_15(start_time)
  end

  def cx_end
    round_time_15(end_time)
  end

  def display_status
    return status if program.v2

    return alayacare_status if alayacare_status.present?

    return "cancelled" if canceled

    end_time < Time.zone.now ? "completed" : "scheduled"
  end

  def update_status_on_cancel
    if canceled_changed?
      if canceled
        self.status = "cancelled"
      else
        last_event = visit_events.last

        self.status = case last_event&.event_type
                      when "clocked_in"
                        "clocked"
                      when "complete"
                        "completed"
                      else
                        "scheduled"
                      end
      end
    end

    true
  end

  def get_provider_athena_id
    provider_tier_list = {
      "nurse_practitioner" => 4,
      "social_worker"      => 3,
      "field_provider"     => 2,
      "witness"            => 1
    }

    # default result
    result = field_provider.athena_id
    result_tier = provider_tier_list["field_provider"]

    providers.each do |provider|
      provider_tier = provider_tier_list[provider.role]

      higher_priority = provider_tier.present? &&
                        provider_tier >= result_tier &&
                        provider.athena_id.present?

      if higher_priority
        result = provider.athena_id
        result_tier = provider_tier
      end
    end

    result
  end

  # Make service instructions sticky across visits.  Address notes override local column.
  def service_instructions
    patient&.address&.notes.presence || self[:service_instructions]
  end

  def lat_long
    if address.present? && address.latitude.present? && address.longitude.present?
      "#{address.latitude},#{address.longitude}"
    end
  end

  def update_arrival_window
    # Add arrival_window_start and arrival_window_end before saving
    if will_save_change_to_attribute?(:start_time) || arrival_window_start.blank?
      existing_window = [arrival_window_start, arrival_window_end]

      timezone = patient&.address&.timezone
      block_schedule = program&.arrival_window_block_schedule
      offset = program&.arrival_window_offset_minutes

      result = Routing::GetArrivalWindow.call(start_time, timezone, block_schedule, offset, existing_window)
      if result.success?
        self.arrival_window_start = result.payload[0]
        self.arrival_window_end = result.payload[1]
      end
    end
    true # never prevent save
  end

  # Paper trail story association
  def trailed_related_content
    visit_services | visit_events | visit_resources | work_sessions
  end

  def to_builder
    Jbuilder.new do |visit|
      visit.call(self,
                 :id,
                 :start_time,
                 :end_time,
                 :service_instructions,
                 :canceled,
                 :external_id,
                 :status,
                 :alayacare_status)
      visit.field_provider field_provider.to_builder.attributes! if field_provider
      visit.patient patient.to_builder(include_programs: true).attributes!
      visit.program program.to_builder.attributes!
      visit.services services.map {|s| s.to_builder.attributes! }
      visit.visit_type visit_type.to_builder.attributes!
      visit.resources visit.visit_resources
    end
  end

  def confirmation_needed?
    return false if visit_type.outreach_visit?
    window_changed = saved_change_to_attribute?(:arrival_window_start) || saved_change_to_attribute?(:arrival_window_end)
    window_missing_and_start_changed = (arrival_window_start.nil? || arrival_window_end.nil?) && saved_change_to_attribute?(:start_time)
    window_changed || window_missing_and_start_changed
  end

  def reset_confirmed_needed?
    window_changed = will_save_change_to_attribute?(:arrival_window_start) || will_save_change_to_attribute?(:arrival_window_end)
    window_missing_and_start_changed = (arrival_window_start.nil? || arrival_window_end.nil?) && will_save_change_to_attribute?(:start_time)
    (confirmed.nil? || window_changed || window_missing_and_start_changed) && !will_save_change_to_attribute?(:confirmed)
  end

  def reset_confirmed
    self.confirmed = false
  end

  def send_confirmation
    if program.demand_partner.short_name == "Optum Serve"
      if patient.contact_email.present? && patient.consent_to_email
        Lambdaforce::PushRecord.call(salesforce_push_body("Email"))
      end
    else

      AppointmentConfirmation.delay.call(self)
    end
  end

  def udpate_reschedule_count
    self.reschedule_count = (reschedule_count || 0) + 1
  end

  def should_push_to_salesforce?
    program.v2?
  end

  def should_push_to_athena?
    program.v2? && !visit_type.outreach_visit?
  end

  def to_ma_object
    fields = %i[arrival_window_end arrival_window_start ma_id start_time end_time cx_start cx_end canceled confirmed
                status service_instructions]
    associations = %i[field_provider patient program visit_type]
    make_ma_object(fields, associations)
  end
end
