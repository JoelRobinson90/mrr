# frozen_string_literal: true

ALAYACARE_API_VISIT_FIELDS = %i[
  id
  alayacare_visit_id
  fp_id
  location
  start_time
  end_time
  demand_partner_id
  demand_partner
  patient
  status
  client_id
  visit_type
  drive_time
  drive_distance
  cx_start
  cx_end
  visit_id
  ma_visit
  notes
  fp_name
  cancelled
  local
  services
  service_instructions
  cancel_code
  arrival_window_start
  arrival_window_end
  program
  clock_in
  clock_out
  visit_group_id
  athena_telehealth_url
  confirmed
  resources
].freeze

AlayacareApiVisit = Struct.new(*ALAYACARE_API_VISIT_FIELDS, keyword_init: true)
