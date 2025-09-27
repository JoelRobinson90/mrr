# frozen_string_literal: true

# == Schema Information
#
# Table name: scheduler_logs
#
#  id                                            :bigint           not null, primary key
#  best_drive_time                               :integer
#  blocked_for_race_condition                    :boolean
#  blocked_shifts_count                          :integer
#  blocked_shifts_dump                           :string
#  blocking_roles                                :string
#  buffer_time                                   :integer
#  days_until_soonest_option                     :float
#  disposition                                   :string
#  drive_score                                   :integer
#  drive_time_breakpoints                        :string
#  drive_time_chosen                             :integer
#  drive_weight                                  :integer
#  elapsed_time_for_choice                       :float
#  elapsed_time_for_results                      :integer
#  end_date                                      :date
#  end_time_chosen                               :datetime
#  enforce_service_area                          :boolean          default(FALSE)
#  existing_visits_count                         :integer
#  existing_visits_dump                          :string
#  field_provider_name                           :string
#  full_preferred_provider_option_chosen         :boolean
#  grace_period_options_count                    :integer
#  high_rank_absolute_threshold                  :integer
#  high_rank_percentile_threshold                :integer
#  hours_before_first_option                     :integer
#  index_chosen                                  :integer
#  initial_slots_count                           :integer
#  max_distance                                  :integer
#  max_grace_period                              :integer
#  max_results                                   :integer
#  medium_rank_absolute_threshold                :integer
#  medium_rank_percentile_threshold              :integer
#  no_location_shifts_count                      :integer
#  no_location_shifts_dump                       :string
#  options_blocked_by_no_location_visit          :integer
#  options_count                                 :integer
#  options_dump                                  :string
#  options_without_any_preferred_provider_count  :integer
#  options_without_full_preferred_provider_count :integer
#  partial_preferred_provider_option_chosen      :boolean
#  picks_before_booking                          :integer
#  pre_merge_slots                               :string
#  pre_merge_slots_count_by_role                 :string
#  proximity_score                               :integer
#  proximity_weight                              :integer
#  rank_category_chosen                          :string
#  request_time                                  :datetime
#  rescheduling                                  :boolean          default(FALSE)
#  scheduler_version                             :integer          default(1)
#  shift_shortening_penalty_score                :integer          default(0)
#  shift_shortening_penalty_weight               :integer          default(0)
#  shifts_count                                  :integer
#  shifts_count_by_role                          :string
#  shifts_dump                                   :string
#  start_date                                    :date
#  start_time_chosen                             :datetime
#  total_score                                   :integer
#  utilization_score                             :integer
#  utilization_weight                            :integer
#  valid_slots_count                             :integer
#  virtual_provider_offset                       :integer
#  visit_created                                 :boolean          default(FALSE)
#  visit_error_message                           :string
#  visit_location                                :string
#  worst_drive_time                              :integer
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  patient_id                                    :bigint           not null, indexed
#  run_id                                        :string           not null
#  service_area_id                               :bigint           indexed
#  user_id                                       :bigint           indexed
#  visit_id                                      :bigint           indexed
#
# Indexes
#
#  index_scheduler_logs_on_patient_id       (patient_id)
#  index_scheduler_logs_on_service_area_id  (service_area_id)
#  index_scheduler_logs_on_user_id          (user_id)
#  index_scheduler_logs_on_visit_id         (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#  fk_rails_...  (service_area_id => service_areas.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (visit_id => visits.id)
#
class SchedulerLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :patient
  belongs_to :visit, optional: true

  def display_name
    request_time
  end
end
