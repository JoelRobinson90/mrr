# frozen_string_literal: true

# == Schema Information
#
# Table name: service_requests
#
#  id             :bigint           not null, primary key
#  refusal_reason :string
#  status         :string           default("requested"), not null
#  status_detail  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  ma_id          :string           not null, indexed
#  patient_id     :bigint           not null, indexed => [program_id, service_id]
#  program_id     :bigint           not null, indexed, indexed => [patient_id, service_id]
#  service_id     :bigint           not null, indexed, indexed => [patient_id, program_id]
#
# Indexes
#
#  index_service_requests_on_ma_id        (ma_id)
#  index_service_requests_on_program_id   (program_id)
#  index_service_requests_on_service_id   (service_id)
#  patient_program_service_request_index  (patient_id,program_id,service_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (program_id => programs.id)
#  fk_rails_...  (service_id => services.id)
#
class ServiceRequest < ApplicationRecord
  include PushToSalesforce

  belongs_to :patient
  belongs_to :program
  belongs_to :service

  has_many :covering_visits, lambda {|service_request|
                               where(patient_id: service_request.patient_id, program_id: service_request.program_id, canceled: false)
                             }, source: :visits, through: :service
  delegate :name, to: :service, prefix: true

  def patient_program
    @patient_program ||= PatientProgram.find_by(patient_id: patient_id, program_id: program_id)
  end

  def should_push_to_salesforce?
    program.v2?
  end

  def to_s
    "#{status} service request"
  end
  alias display_name to_s

  def refresh_status
    # Only update status if it's not in a terminal state
    return status unless %w[requested in-progress].include? status

    new_status = if covering_visits.count.positive?
                   "in-progress"
                 else
                   "requested"
                 end

    update(status: new_status) if status != new_status

    status
  end

  def to_ma_object
    fields = %i[status status_detail refusal_reason service_name]
    associations = %i[patient_program]
    make_ma_object(fields, associations)
  end

  def to_builder
    Jbuilder.new do |req|
      req.call(self, :id, :ma_id, :status, :status_detail, :patient_id, :program_id, :service_id)
    end
  end
end
