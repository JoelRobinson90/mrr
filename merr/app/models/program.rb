# frozen_string_literal: true

# == Schema Information
#
# Table name: programs
#
#  id                                  :bigint           not null, primary key
#  active                              :boolean          default(TRUE)
#  arrival_window_block_schedule       :string
#  arrival_window_offset_minutes       :integer
#  drive_time_breakpoints              :string
#  drive_weight                        :integer          default(80), not null
#  enforce_service_area                :boolean          default(FALSE)
#  high_rank_absolute_threshold        :integer          default(90)
#  high_rank_percentile_threshold      :integer          default(90)
#  hours_before_first_option           :integer          default(10), not null
#  max_grace_period                    :integer          default(0)
#  max_results                         :integer
#  max_straight_line_distance_in_miles :integer          default(300), not null
#  medium_rank_absolute_threshold      :integer          default(60)
#  medium_rank_percentile_threshold    :integer          default(60)
#  min_shift_length_in_hours           :float            default(8.0)
#  minutes_of_buffer_time              :integer          default(15), not null
#  name                                :string           not null
#  proximity_weight                    :integer          default(10), not null
#  shift_abbrev_notify_in_days         :integer          default(2)
#  shift_shortening_penalty_weight     :integer          default(0)
#  use_fp_pt_association               :boolean          default(FALSE)
#  utilization_weight                  :integer          default(10), not null
#  v2                                  :boolean          default(FALSE)
#  virtual_provider_offset             :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  alayacare_service_code_id           :string           not null
#  demand_partner_id                   :bigint           not null, indexed
#  ma_id                               :string           indexed
#
# Indexes
#
#  index_programs_on_demand_partner_id  (demand_partner_id)
#  index_programs_on_ma_id              (ma_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
class Program < ApplicationRecord
  belongs_to :demand_partner, optional: false

  has_many :program_services, dependent: :destroy
  has_many :services, through: :program_services

  # Don't allow deleting a program that has visits
  has_many :visits, dependent: :restrict_with_error
  has_many :patient_programs, dependent: :destroy, inverse_of: :program
  has_many :patients, through: :patient_programs
  has_many :ext_acct_programs, dependent: :destroy
  has_many :external_accounts, through: :ext_acct_programs

  has_many :program_visit_types, dependent: :destroy
  has_many :visit_types, through: :program_visit_types
  has_many :service_requests, dependent: :destroy
  has_many :insurance_policies

  has_many :patient_geos
  has_many :service_areas, through: :patient_geos
  has_many :geo_cohorts, through: :patient_geos

  # Paper trail story association
  def trailed_related_content
    visit_types
  end

  validate :validate_drive_time_breakpoints

  def to_builder(include_demand_partner = true, include_services = true, include_visit_types = true)
    Jbuilder.new do |program|
      program.call(self,
                   :id,
                   :name,
                   :alayacare_service_code_id,
                   :demand_partner_id,
                   :created_at,
                   :updated_at,
                   :v2,
                   :active)
      program.demand_partner demand_partner.to_builder.attributes! if include_demand_partner
      program.services services.map {|s| s.to_builder.attributes! } if include_services
      program.visit_types visit_types.map {|s| s.to_builder.attributes! } if include_visit_types
    end
  end

  def to_s
    name
  end

  def validate_drive_time_breakpoints
    if drive_time_breakpoints.present?
      begin
        parsed_breakpoints = JSON.parse(drive_time_breakpoints)
        raise "not an array" unless parsed_breakpoints.is_a?(Array)

        parsed_breakpoints.each do |breakpoint|
          unless breakpoint["drive"].is_a?(Numeric) && breakpoint["score"].is_a?(Numeric)
            errors.add(:drive_time_breakpoints, "are not in the valid format [{\"drive\": 10, \"score\": 10}]")
            return
          end
          unless breakpoint["drive"] >= 0 && breakpoint["score"] >= 0 && breakpoint["score"] <= 100
            errors.add(:drive_time_breakpoints, "contains invalid drive or score value")
            return
          end
        end
      rescue StandardError => e
        errors.add(:drive_time_breakpoints, "could not be parsed: #{e.message}")
      end
    end
    true
  end

  def to_ma_object
    fields = [:name]
    make_ma_object(fields, associations = [:demand_partner])
  end
end
