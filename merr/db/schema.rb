# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_05_19_004124) do

  create_sequence "admin_note_ma_id"
  create_sequence "cancel_code_ma_id"
  create_sequence "field_org_ma_id"
  create_sequence "field_provider_ma_id"
  create_sequence "patient_ma_id"
  create_sequence "patient_program_ma_id"
  create_sequence "service_request_ma_id"
  create_sequence "visit_ma_id"
  create_sequence "visit_type_ma_id"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_line_one"
    t.string "address_line_two"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "latitude"
    t.string "longitude"
    t.string "notes"
    t.string "timezone"
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.string "county"
    t.boolean "geocoding_partial_match"
    t.boolean "geocoding_approximate_result"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "admin_notes", force: :cascade do |t|
    t.string "content"
    t.string "notable_type", null: false
    t.bigint "notable_id", null: false
    t.integer "creator_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ma_id"
    t.index ["creator_id"], name: "index_admin_notes_on_creator_id"
    t.index ["ma_id"], name: "index_admin_notes_on_ma_id"
    t.index ["notable_type", "notable_id"], name: "index_admin_notes_on_notable_type_and_notable_id"
  end

  create_table "alayacare_form_answers", force: :cascade do |t|
    t.bigint "response_id", null: false
    t.string "field_tag"
    t.text "reply"
    t.string "processor"
    t.text "question"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "raw"
    t.string "approved_date"
    t.string "alayacare_answer_id"
    t.index ["response_id"], name: "alayacare_form_response_answer_index"
  end

  create_table "alayacare_form_responses", force: :cascade do |t|
    t.bigint "patient_id"
    t.bigint "appointment_id"
    t.string "alayacare_form_identifier"
    t.string "alayacare_client_identifier"
    t.string "alayacare_client_form_identifier"
    t.string "alayacare_service_identifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "processed_file_id"
    t.string "alayacare_patient_id"
    t.string "alayacare_service_id"
    t.index ["appointment_id"], name: "index_alayacare_form_responses_on_appointment_id"
    t.index ["patient_id"], name: "index_alayacare_form_responses_on_patient_id"
  end

  create_table "alayacare_processed_files", force: :cascade do |t|
    t.datetime "processed_on", null: false
    t.boolean "errored", default: false, null: false
    t.string "filename", null: false
    t.text "error_messages"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "form_template"
    t.boolean "processed"
    t.integer "rows", default: 0, null: false
  end

  create_table "alayacare_service_codes", force: :cascade do |t|
    t.string "name"
    t.integer "duration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "appointments", force: :cascade do |t|
    t.string "status", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.bigint "field_provider_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "block_start_time"
    t.datetime "block_end_time"
    t.bigint "patient_id"
    t.integer "cohort_id"
    t.integer "route_index"
    t.string "issue_reason"
    t.text "dispatch_notes"
    t.integer "base_duration", default: 30
    t.float "drive_time"
    t.index ["field_provider_id"], name: "index_appointments_on_field_provider_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
  end

  create_table "athena_custom_fields", force: :cascade do |t|
    t.string "name"
    t.integer "athena_id"
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "athena_departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "timezone", null: false
    t.string "generic_timezone", null: false
    t.integer "athena_id", null: false
    t.bigint "demand_partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["demand_partner_id"], name: "index_athena_departments_on_demand_partner_id"
  end

  create_table "availability_slots", force: :cascade do |t|
    t.string "day_of_week", null: false
    t.integer "start_hour", null: false
    t.integer "end_hour", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "background_job_results", force: :cascade do |t|
    t.string "status", null: false
    t.string "job_type", null: false
    t.string "label"
    t.string "message"
    t.string "error_list", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cancel_codes", force: :cascade do |t|
    t.integer "alayacare_id"
    t.string "code", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ma_id"
    t.integer "athena_id"
    t.index ["ma_id"], name: "index_cancel_codes_on_ma_id"
  end

  create_table "certifications", force: :cascade do |t|
    t.string "name"
    t.boolean "medarrive_required", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cohorts", force: :cascade do |t|
    t.string "name"
    t.bigint "demand_partner_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "block_size"
    t.integer "vaccines_per_block"
    t.integer "total_vaccines"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "route_geojson"
    t.integer "split_counter", default: 0
    t.boolean "regional", default: true
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_cohorts_on_deleted_at"
    t.index ["demand_partner_id"], name: "index_cohorts_on_demand_partner_id"
  end

  create_table "communication_logs", force: :cascade do |t|
    t.string "communication_type"
    t.text "body"
    t.string "subject"
    t.string "destination"
    t.string "sender"
    t.string "event_trigger"
    t.string "category"
    t.bigint "patient_id", null: false
    t.string "context_type"
    t.bigint "context_id"
    t.string "direction", default: "outbound", null: false
    t.string "reciept"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["context_type", "context_id"], name: "index_communication_logs_on_context_type_and_context_id"
    t.index ["patient_id"], name: "index_communication_logs_on_patient_id"
  end

  create_table "covid_vaccinations", force: :cascade do |t|
    t.string "vaccine_type"
    t.boolean "reaction", default: false, null: false
    t.text "reaction_notes"
    t.bigint "appointment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "vaccine_quantity", default: 1, null: false
    t.string "lot"
    t.string "route"
    t.string "site"
    t.string "dose"
    t.datetime "expire"
    t.index ["appointment_id"], name: "index_covid_vaccinations_on_appointment_id"
  end

  create_table "custom_field_responses", force: :cascade do |t|
    t.string "value"
    t.bigint "patient_id"
    t.bigint "demand_partner_custom_field_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "program_id"
    t.index ["demand_partner_custom_field_id"], name: "index_custom_field_responses_on_demand_partner_custom_field_id"
    t.index ["patient_id"], name: "index_custom_field_responses_on_patient_id"
    t.index ["program_id"], name: "index_custom_field_responses_on_program_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "demand_coordinators", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.bigint "demand_partner_id", null: false
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["demand_partner_id"], name: "index_demand_coordinators_on_demand_partner_id"
  end

  create_table "demand_partner_custom_fields", force: :cascade do |t|
    t.string "csv_column_name", null: false
    t.string "crm_field_name"
    t.bigint "demand_partner_id"
    t.string "data_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ehr_field_name"
    t.string "display_name"
    t.boolean "v2"
    t.index ["demand_partner_id"], name: "index_demand_partner_custom_fields_on_demand_partner_id"
  end

  create_table "demand_partners", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "redox_source_id"
    t.integer "alayacare_id"
    t.string "ma_id"
    t.string "short_name", null: false
    t.index ["ma_id"], name: "index_demand_partners_on_ma_id"
  end

  create_table "event_store_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "event_type", null: false
    t.binary "metadata"
    t.binary "data", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_type"], name: "index_event_store_events_on_event_type"
  end

  create_table "event_store_events_in_streams", id: :serial, force: :cascade do |t|
    t.string "stream", null: false
    t.integer "position"
    t.uuid "event_id", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "ext_acct_programs", force: :cascade do |t|
    t.bigint "external_account_id"
    t.bigint "program_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_account_id", "program_id"], name: "index_ext_acct_programs_on_external_account_id_and_program_id"
    t.index ["program_id", "external_account_id"], name: "index_ext_acct_programs_on_program_id_and_external_account_id"
  end

  create_table "external_accounts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.bigint "demand_partner_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["demand_partner_id"], name: "index_external_accounts_on_demand_partner_id"
  end

  create_table "extra_vaccine_recipients", force: :cascade do |t|
    t.string "name"
    t.date "date_of_birth"
    t.string "phone_number"
    t.boolean "consent_to_text", default: false
    t.boolean "confirmed", default: false
    t.boolean "complete", default: false
    t.bigint "appointment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "deleted", default: false
    t.string "race"
    t.string "ethnicity"
    t.string "unable_to_vaccinate"
    t.string "unable_to_vaccinate_reason"
    t.bigint "covid_vaccination_id"
    t.index ["appointment_id"], name: "index_extra_vaccine_recipients_on_appointment_id"
    t.index ["covid_vaccination_id"], name: "index_extra_vaccine_recipients_on_covid_vaccination_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.string "name"
    t.bigint "demand_partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["demand_partner_id"], name: "index_facilities_on_demand_partner_id"
  end

  create_table "field_admins", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.bigint "field_org_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_org_id"], name: "index_field_admins_on_field_org_id"
  end

  create_table "field_dispatchers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.bigint "field_org_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_org_id"], name: "index_field_dispatchers_on_field_org_id"
  end

  create_table "field_org_certifications", force: :cascade do |t|
    t.bigint "certification_id", null: false
    t.bigint "field_org_id", null: false
    t.boolean "required", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["certification_id"], name: "index_field_org_certifications_on_certification_id"
    t.index ["field_org_id"], name: "index_field_org_certifications_on_field_org_id"
  end

  create_table "field_org_trainings", force: :cascade do |t|
    t.bigint "training_id", null: false
    t.bigint "field_org_id", null: false
    t.boolean "required", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_org_id"], name: "index_field_org_trainings_on_field_org_id"
    t.index ["training_id"], name: "index_field_org_trainings_on_training_id"
  end

  create_table "field_orgs", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug", null: false
    t.string "ma_id"
    t.index ["ma_id"], name: "index_field_orgs_on_ma_id"
  end

  create_table "field_provider_certifications", force: :cascade do |t|
    t.bigint "certification_id", null: false
    t.bigint "field_provider_id", null: false
    t.date "effective_date"
    t.date "expiration_date"
    t.string "license_number"
    t.datetime "validated_at"
    t.bigint "validated_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["certification_id"], name: "index_field_provider_certifications_on_certification_id"
    t.index ["field_provider_id"], name: "index_field_provider_certifications_on_field_provider_id"
    t.index ["validated_by_id"], name: "index_field_provider_certifications_on_validated_by_id"
  end

  create_table "field_provider_trainings", force: :cascade do |t|
    t.bigint "training_id", null: false
    t.bigint "field_provider_id", null: false
    t.integer "quiz_score"
    t.datetime "validated_at"
    t.bigint "validated_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_provider_id"], name: "index_field_provider_trainings_on_field_provider_id"
    t.index ["training_id"], name: "index_field_provider_trainings_on_training_id"
    t.index ["validated_by_id"], name: "index_field_provider_trainings_on_validated_by_id"
  end

  create_table "field_providers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.date "date_of_birth"
    t.bigint "field_org_id", null: false
    t.string "provider_level"
    t.string "bio"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "license_number"
    t.string "external_id", null: false
    t.string "ma_id"
    t.integer "athena_id"
    t.string "role", default: "field_provider"
    t.string "push_to_wheniwork_error"
    t.index ["external_id"], name: "index_field_providers_on_external_id", unique: true
    t.index ["field_org_id"], name: "index_field_providers_on_field_org_id"
    t.index ["ma_id"], name: "index_field_providers_on_ma_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "geo_cohorts", force: :cascade do |t|
    t.string "name"
    t.bigint "service_area_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_area_id"], name: "index_geo_cohorts_on_service_area_id"
  end

  create_table "hra_surveys", force: :cascade do |t|
    t.jsonb "survey"
    t.bigint "patient_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["patient_id"], name: "index_hra_surveys_on_patient_id"
  end

  create_table "insurance_policies", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "program_id", null: false
    t.integer "insurance_package_id", default: 0, null: false
    t.string "policy_holder_first_name"
    t.string "policy_holder_last_name"
    t.string "policy_holder_sex"
    t.integer "relationship_to_insured_id", default: 1, null: false
    t.string "insurance_id_number", null: false
    t.integer "insurance_sequence_number", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["patient_id"], name: "index_insurance_policies_on_patient_id"
    t.index ["program_id"], name: "index_insurance_policies_on_program_id"
  end

  create_table "insurances", force: :cascade do |t|
    t.string "member_id"
    t.string "group_id"
    t.text "plan_description"
    t.string "bin_number"
    t.date "effective_date"
    t.date "renewal_date"
    t.bigint "patient_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "rx_pcn"
    t.string "rx_group"
    t.string "name"
    t.index ["patient_id"], name: "index_insurances_on_patient_id"
  end

  create_table "kustomer_csv_upload_failures", force: :cascade do |t|
    t.binary "content"
    t.bigint "kustomer_csv_upload_id", null: false
    t.string "error"
    t.integer "csv_row_number"
    t.string "patient_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["kustomer_csv_upload_id"], name: "index_kustomer_csv_upload_failures_on_kustomer_csv_upload_id"
  end

  create_table "kustomer_csv_uploads", force: :cascade do |t|
    t.binary "content"
    t.bigint "user_id", null: false
    t.bigint "demand_partner_id", null: false
    t.string "csv_name", null: false
    t.integer "total_rows", null: false
    t.integer "total_success"
    t.integer "total_fails"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["demand_partner_id"], name: "index_kustomer_csv_uploads_on_demand_partner_id"
    t.index ["user_id"], name: "index_kustomer_csv_uploads_on_user_id"
  end

  create_table "medarrive_admins", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "phone_number"
  end

  create_table "medarrive_clinical_operations", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "medarrive_customer_supports", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "demand_partner_id", null: false
    t.json "redox_object"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "appointment_id"
    t.index ["appointment_id"], name: "index_orders_on_appointment_id"
    t.index ["demand_partner_id"], name: "index_orders_on_demand_partner_id"
    t.index ["patient_id"], name: "index_orders_on_patient_id"
  end

  create_table "outreach_campaign_contacts", force: :cascade do |t|
    t.string "kustomer_customer_id", null: false
    t.string "status", default: "created", null: false
    t.bigint "outreach_campaign_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "kustomer_bulk_id"
    t.index ["outreach_campaign_id", "kustomer_customer_id"], name: "index_outreach_campaign_contacts_on_campaign_id_and_customer_id", unique: true
    t.index ["outreach_campaign_id"], name: "index_outreach_campaign_contacts_on_outreach_campaign_id"
    t.index ["status"], name: "index_outreach_campaign_contacts_on_status"
  end

  create_table "outreach_campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.integer "rate_per_hour", default: 60, null: false
    t.string "kustomer_tag_id", null: false
    t.string "kustomer_search_id", null: false
    t.json "kustomer_conversation_fields", default: {}, null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "program_id"
    t.time "weekday_not_before_local_time", default: "2000-01-01 09:00:00", null: false
    t.time "weekday_not_after_local_time", default: "2000-01-01 17:00:00", null: false
    t.string "timezone", default: "America/New_York", null: false
    t.time "saturday_not_before_local_time"
    t.time "saturday_not_after_local_time"
    t.time "sunday_not_before_local_time"
    t.time "sunday_not_after_local_time"
    t.index ["program_id"], name: "index_outreach_campaigns_on_program_id"
  end

  create_table "patient_geos", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "program_id", null: false
    t.bigint "geo_cohort_id", null: false
    t.bigint "service_area_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["geo_cohort_id"], name: "index_patient_geos_on_geo_cohort_id"
    t.index ["patient_id", "program_id"], name: "index_patient_geos_on_patient_id_and_program_id", unique: true
    t.index ["patient_id"], name: "index_patient_geos_on_patient_id"
    t.index ["program_id"], name: "index_patient_geos_on_program_id"
    t.index ["service_area_id"], name: "index_patient_geos_on_service_area_id"
  end

  create_table "patient_programs", force: :cascade do |t|
    t.bigint "patient_id"
    t.bigint "program_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ma_id"
    t.index ["ma_id"], name: "index_patient_programs_on_ma_id"
    t.index ["patient_id", "program_id"], name: "index_patient_programs_on_patient_id_and_program_id"
    t.index ["program_id", "patient_id"], name: "index_patient_programs_on_program_id_and_patient_id"
  end

  create_table "patient_prospects", force: :cascade do |t|
    t.string "medical_record_number"
    t.bigint "demand_partner_id"
    t.string "zipcode"
    t.date "discharge_start"
    t.date "discharge_end"
    t.string "diagnosis", array: true
    t.string "preferred_language"
    t.string "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_patient_prospects_on_deleted_at"
    t.index ["demand_partner_id"], name: "index_patient_prospects_on_demand_partner_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "middle_initial"
    t.string "phone_number"
    t.string "secondary_phone_number"
    t.string "medical_record_number"
    t.string "emergency_contact_name"
    t.string "emergency_contact_phone_number"
    t.bigint "demand_partner_id", null: false
    t.text "patient_notes"
    t.bigint "primary_care_physician_id"
    t.string "sex"
    t.string "gender"
    t.string "preferred_pronouns"
    t.string "status", default: "Created", null: false
    t.boolean "consent_to_text", default: false, null: false
    t.boolean "needs_hra_survey"
    t.string "preferred_language"
    t.string "race"
    t.string "ethnicity"
    t.string "phone_number_type"
    t.string "secondary_phone_number_type"
    t.string "region"
    t.string "primary_risk_category"
    t.string "external_id", null: false
    t.string "contact_email"
    t.string "ma_id"
    t.integer "athena_id"
    t.string "datalake_id"
    t.string "push_to_athena_error"
    t.boolean "consent_to_email", default: false, null: false
    t.string "preferred_contact_method"
    t.index ["demand_partner_id"], name: "index_patients_on_demand_partner_id"
    t.index ["external_id"], name: "index_patients_on_external_id", unique: true
    t.index ["ma_id"], name: "index_patients_on_ma_id"
    t.index ["primary_care_physician_id"], name: "index_patients_on_primary_care_physician_id"
  end

  create_table "pharmacies", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone_number"
    t.bigint "patient_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["patient_id"], name: "index_pharmacies_on_patient_id"
  end

  create_table "primary_care_physicians", force: :cascade do |t|
    t.string "name", null: false
    t.string "office_name"
    t.string "office_phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "program_services", force: :cascade do |t|
    t.bigint "program_id"
    t.bigint "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["program_id", "service_id"], name: "index_program_services_on_program_id_and_service_id"
  end

  create_table "program_visit_types", force: :cascade do |t|
    t.bigint "program_id"
    t.bigint "visit_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["program_id", "visit_type_id"], name: "index_program_visit_types_on_program_id_and_visit_type_id"
    t.index ["visit_type_id", "program_id"], name: "index_program_visit_types_on_visit_type_id_and_program_id"
  end

  create_table "programs", force: :cascade do |t|
    t.string "name", null: false
    t.string "alayacare_service_code_id", null: false
    t.bigint "demand_partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "minutes_of_buffer_time", default: 15, null: false
    t.integer "max_results"
    t.integer "hours_before_first_option", default: 10, null: false
    t.integer "max_straight_line_distance_in_miles", default: 300, null: false
    t.integer "drive_weight", default: 80, null: false
    t.integer "proximity_weight", default: 10, null: false
    t.integer "utilization_weight", default: 10, null: false
    t.integer "high_rank_percentile_threshold", default: 90
    t.integer "medium_rank_percentile_threshold", default: 60
    t.integer "high_rank_absolute_threshold", default: 90
    t.integer "medium_rank_absolute_threshold", default: 60
    t.integer "max_grace_period", default: 0
    t.boolean "use_fp_pt_association", default: false
    t.float "min_shift_length_in_hours", default: 8.0
    t.integer "shift_abbrev_notify_in_days", default: 2
    t.integer "shift_shortening_penalty_weight", default: 0
    t.integer "arrival_window_offset_minutes"
    t.string "arrival_window_block_schedule"
    t.string "drive_time_breakpoints"
    t.integer "virtual_provider_offset"
    t.boolean "enforce_service_area", default: false
    t.boolean "v2", default: false
    t.string "ma_id"
    t.boolean "active", default: true
    t.index ["demand_partner_id"], name: "index_programs_on_demand_partner_id"
    t.index ["ma_id"], name: "index_programs_on_ma_id"
  end

  create_table "provider_preferences", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "field_provider_id", null: false
    t.string "source", default: "care_team", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_provider_id"], name: "index_provider_preferences_on_field_provider_id"
    t.index ["patient_id"], name: "index_provider_preferences_on_patient_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "certification"
    t.string "drchrono_id"
    t.string "drchrono_access_token"
    t.string "drchrono_refresh_token"
    t.datetime "drchrono_token_expires"
    t.string "workpath_id"
    t.string "workpath_access_token"
    t.string "workpath_refresh_token"
    t.datetime "workpath_token_expires"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "redox_clinical_summaries", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "demand_partner_id", null: false
    t.json "redox_object"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.index ["demand_partner_id"], name: "index_redox_clinical_summaries_on_demand_partner_id"
    t.index ["order_id"], name: "index_redox_clinical_summaries_on_order_id"
    t.index ["patient_id"], name: "index_redox_clinical_summaries_on_patient_id"
  end

  create_table "redox_destinations", force: :cascade do |t|
    t.string "redox_destination_id", null: false
    t.string "name", null: false
    t.bigint "demand_partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "data_model"
    t.index ["demand_partner_id"], name: "index_redox_destinations_on_demand_partner_id"
  end

  create_table "redox_inbound_requests", force: :cascade do |t|
    t.json "body"
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "resulting_in_type"
    t.bigint "resulting_in_id"
    t.string "resulting_errors"
    t.integer "duplicate_of_id"
    t.index ["duplicate_of_id"], name: "index_redox_inbound_requests_on_duplicate_of_id"
    t.index ["resulting_in_type", "resulting_in_id"], name: "index_redox_inbound_requests_on_resulting_in"
  end

  create_table "redox_pdf_uploads", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "order_id", null: false
    t.string "filename", null: false
    t.string "redox_receipt"
    t.bigint "patient_id", null: false
    t.json "redox_object"
    t.index ["appointment_id"], name: "index_redox_pdf_uploads_on_appointment_id"
    t.index ["order_id"], name: "index_redox_pdf_uploads_on_order_id"
    t.index ["patient_id"], name: "index_redox_pdf_uploads_on_patient_id"
  end

  create_table "scheduler_logs", force: :cascade do |t|
    t.string "run_id", null: false
    t.datetime "request_time"
    t.bigint "patient_id", null: false
    t.bigint "user_id"
    t.string "visit_location"
    t.date "start_date"
    t.date "end_date"
    t.integer "buffer_time"
    t.integer "max_results"
    t.integer "hours_before_first_option"
    t.integer "max_distance"
    t.integer "elapsed_time_for_results"
    t.integer "existing_visits_count"
    t.string "existing_visits_dump"
    t.integer "blocked_shifts_count"
    t.string "blocked_shifts_dump"
    t.integer "no_location_shifts_count"
    t.string "no_location_shifts_dump"
    t.integer "shifts_count"
    t.string "shifts_dump"
    t.integer "initial_slots_count"
    t.integer "valid_slots_count"
    t.integer "options_blocked_by_no_location_visit"
    t.integer "options_count"
    t.string "options_dump"
    t.float "days_until_soonest_option"
    t.integer "best_drive_time"
    t.integer "worst_drive_time"
    t.boolean "visit_created", default: false
    t.boolean "blocked_for_race_condition"
    t.string "visit_error_message"
    t.float "elapsed_time_for_choice"
    t.integer "picks_before_booking"
    t.integer "index_chosen"
    t.integer "drive_time_chosen"
    t.datetime "start_time_chosen"
    t.datetime "end_time_chosen"
    t.string "field_provider_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "total_score"
    t.integer "drive_score"
    t.integer "proximity_score"
    t.integer "utilization_score"
    t.bigint "visit_id"
    t.integer "drive_weight"
    t.integer "proximity_weight"
    t.integer "utilization_weight"
    t.integer "high_rank_percentile_threshold"
    t.integer "medium_rank_percentile_threshold"
    t.integer "high_rank_absolute_threshold"
    t.integer "medium_rank_absolute_threshold"
    t.string "rank_category_chosen"
    t.integer "scheduler_version", default: 1
    t.integer "max_grace_period"
    t.integer "grace_period_options_count"
    t.boolean "rescheduling", default: false
    t.integer "shift_shortening_penalty_score", default: 0
    t.integer "shift_shortening_penalty_weight", default: 0
    t.string "drive_time_breakpoints"
    t.integer "virtual_provider_offset"
    t.boolean "enforce_service_area", default: false
    t.bigint "service_area_id"
    t.string "pre_merge_slots"
    t.string "disposition"
    t.string "blocking_roles"
    t.string "shifts_count_by_role"
    t.string "pre_merge_slots_count_by_role"
    t.integer "options_without_any_preferred_provider_count"
    t.integer "options_without_full_preferred_provider_count"
    t.boolean "full_preferred_provider_option_chosen"
    t.boolean "partial_preferred_provider_option_chosen"
    t.index ["patient_id"], name: "index_scheduler_logs_on_patient_id"
    t.index ["service_area_id"], name: "index_scheduler_logs_on_service_area_id"
    t.index ["user_id"], name: "index_scheduler_logs_on_user_id"
    t.index ["visit_id"], name: "index_scheduler_logs_on_visit_id"
  end

  create_table "service_areas", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "service_requests", force: :cascade do |t|
    t.string "ma_id", null: false
    t.bigint "patient_id", null: false
    t.bigint "program_id", null: false
    t.bigint "service_id", null: false
    t.string "status", default: "requested", null: false
    t.string "status_detail"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "refusal_reason"
    t.index ["ma_id"], name: "index_service_requests_on_ma_id"
    t.index ["patient_id", "program_id", "service_id"], name: "patient_program_service_request_index"
    t.index ["program_id"], name: "index_service_requests_on_program_id"
    t.index ["service_id"], name: "index_service_requests_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.string "alayacare_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "duration", default: 0, null: false
    t.integer "athena_id"
  end

  create_table "sms_templates", force: :cascade do |t|
    t.bigint "demand_partner_id", null: false
    t.string "message_type", null: false
    t.string "message_body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["demand_partner_id"], name: "index_sms_templates_on_demand_partner_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "patient_id", null: false
    t.bigint "appointment_id"
    t.jsonb "response", default: {}
    t.datetime "responded_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["appointment_id"], name: "index_surveys_on_appointment_id"
    t.index ["name"], name: "index_surveys_on_name"
    t.index ["patient_id"], name: "index_surveys_on_patient_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.string "description"
    t.string "color", default: "#FFF", null: false
    t.string "group", default: "Appointment", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_tags_on_deleted_at"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "trainings", force: :cascade do |t|
    t.string "name"
    t.string "training_url"
    t.string "quiz_url"
    t.boolean "medarrive_required", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "uploaded_data_imports", force: :cascade do |t|
    t.binary "content"
    t.boolean "processed", default: false, null: false
    t.bigint "user_id", null: false
    t.string "content_type", null: false
    t.bigint "demand_partner_id", null: false
    t.string "operation_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["demand_partner_id"], name: "index_uploaded_data_imports_on_demand_partner_id"
    t.index ["user_id"], name: "index_uploaded_data_imports_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "authentication_token"
    t.datetime "authentication_token_created_at"
    t.boolean "has_random_password", default: false
    t.bigint "account_id"
    t.string "account_type"
    t.boolean "deactivated", default: false, null: false
    t.string "provider"
    t.string "uid"
    t.index ["account_type", "account_id"], name: "index_users_on_account_type_and_account_id"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.string "foreign_type"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  create_table "visit_events", force: :cascade do |t|
    t.datetime "time", null: false
    t.string "location"
    t.string "event_type"
    t.bigint "field_provider_id", null: false
    t.bigint "visit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_provider_id"], name: "index_visit_events_on_field_provider_id"
    t.index ["visit_id"], name: "index_visit_events_on_visit_id"
  end

  create_table "visit_groups", force: :cascade do |t|
  end

  create_table "visit_request_services", force: :cascade do |t|
    t.bigint "visit_request_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id", "visit_request_id"], name: "index_visit_request_services_on_service_id_and_visit_request_id"
    t.index ["service_id"], name: "index_visit_request_services_on_service_id"
    t.index ["visit_request_id", "service_id"], name: "index_visit_request_services_on_visit_request_id_and_service_id"
    t.index ["visit_request_id"], name: "index_visit_request_services_on_visit_request_id"
  end

  create_table "visit_requests", force: :cascade do |t|
    t.bigint "program_id", null: false
    t.bigint "patient_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_visit_requests_on_creator_id"
    t.index ["patient_id"], name: "index_visit_requests_on_patient_id"
    t.index ["program_id"], name: "index_visit_requests_on_program_id"
  end

  create_table "visit_resource_requirements", force: :cascade do |t|
    t.bigint "visit_type_id"
    t.string "provider_role", null: false
    t.integer "duration", null: false
    t.integer "offset", default: 0
    t.boolean "in_home", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "use_preferred_provider", default: true
    t.index ["visit_type_id"], name: "index_visit_resource_requirements_on_visit_type_id"
  end

  create_table "visit_resources", force: :cascade do |t|
    t.bigint "field_provider_id"
    t.bigint "visit_id"
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.boolean "in_home", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_provider_id"], name: "index_visit_resources_on_field_provider_id"
    t.index ["visit_id"], name: "index_visit_resources_on_visit_id"
  end

  create_table "visit_services", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id", "visit_id"], name: "index_visit_services_on_service_id_and_visit_id"
    t.index ["visit_id", "service_id"], name: "index_visit_services_on_visit_id_and_service_id"
  end

  create_table "visit_type_services", force: :cascade do |t|
    t.bigint "visit_type_id"
    t.bigint "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["visit_type_id", "service_id"], name: "index_visit_type_services_on_visit_type_id_and_service_id"
  end

  create_table "visit_types", force: :cascade do |t|
    t.string "name", null: false
    t.integer "duration", default: 0, null: false
    t.string "alayacare_id"
    t.bigint "program_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ma_id"
    t.integer "athena_id"
    t.boolean "plus_ones_enabled"
    t.boolean "outreach_visit", default: false
    t.index ["ma_id"], name: "index_visit_types_on_ma_id"
    t.index ["program_id"], name: "index_visit_types_on_program_id"
  end

  create_table "visits", force: :cascade do |t|
    t.string "external_id", null: false
    t.bigint "patient_id", null: false
    t.bigint "field_provider_id"
    t.bigint "program_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.string "service_instructions"
    t.boolean "canceled", default: false
    t.bigint "cancel_code_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "visit_type_id", null: false
    t.bigint "visit_request_id"
    t.string "alayacare_status"
    t.datetime "arrival_window_start"
    t.datetime "arrival_window_end"
    t.integer "original_visit_id"
    t.integer "next_linked_visit_id"
    t.integer "previous_linked_visit_id"
    t.integer "reschedule_count"
    t.string "status", default: "scheduled"
    t.string "ma_id"
    t.integer "athena_id"
    t.integer "athena_encounter_id"
    t.string "athena_telehealth_url"
    t.boolean "confirmed", default: false
    t.string "push_to_athena_error"
    t.string "push_to_alayacare_error"
    t.integer "visit_group_id"
    t.string "last_athena_sync"
    t.index ["cancel_code_id"], name: "index_visits_on_cancel_code_id"
    t.index ["external_id"], name: "index_visits_on_external_id", unique: true
    t.index ["field_provider_id"], name: "index_visits_on_field_provider_id"
    t.index ["ma_id"], name: "index_visits_on_ma_id"
    t.index ["patient_id"], name: "index_visits_on_patient_id"
    t.index ["program_id"], name: "index_visits_on_program_id"
    t.index ["visit_request_id"], name: "index_visits_on_visit_request_id"
    t.index ["visit_type_id"], name: "index_visits_on_visit_type_id"
  end

  create_table "work_sessions", force: :cascade do |t|
    t.datetime "clock_in", null: false
    t.datetime "clock_out"
    t.string "clock_in_location"
    t.string "clock_out_location"
    t.bigint "field_provider_id", null: false
    t.bigint "visit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_provider_id"], name: "index_work_sessions_on_field_provider_id"
    t.index ["visit_id"], name: "index_work_sessions_on_visit_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_notes", "users", column: "creator_id"
  add_foreign_key "alayacare_form_answers", "alayacare_form_responses", column: "response_id"
  add_foreign_key "alayacare_form_responses", "appointments"
  add_foreign_key "alayacare_form_responses", "patients"
  add_foreign_key "appointments", "patients"
  add_foreign_key "athena_departments", "demand_partners"
  add_foreign_key "cohorts", "demand_partners", on_delete: :cascade
  add_foreign_key "communication_logs", "patients"
  add_foreign_key "covid_vaccinations", "appointments"
  add_foreign_key "custom_field_responses", "programs"
  add_foreign_key "demand_coordinators", "demand_partners"
  add_foreign_key "demand_partner_custom_fields", "demand_partners"
  add_foreign_key "external_accounts", "demand_partners"
  add_foreign_key "extra_vaccine_recipients", "appointments"
  add_foreign_key "extra_vaccine_recipients", "covid_vaccinations"
  add_foreign_key "facilities", "demand_partners"
  add_foreign_key "field_admins", "field_orgs"
  add_foreign_key "field_dispatchers", "field_orgs"
  add_foreign_key "field_org_certifications", "certifications"
  add_foreign_key "field_org_certifications", "field_orgs", on_delete: :cascade
  add_foreign_key "field_org_trainings", "field_orgs", on_delete: :cascade
  add_foreign_key "field_org_trainings", "trainings"
  add_foreign_key "field_provider_certifications", "certifications"
  add_foreign_key "field_provider_certifications", "field_providers"
  add_foreign_key "field_provider_certifications", "users", column: "validated_by_id"
  add_foreign_key "field_provider_trainings", "field_providers"
  add_foreign_key "field_provider_trainings", "trainings"
  add_foreign_key "field_provider_trainings", "users", column: "validated_by_id"
  add_foreign_key "field_providers", "field_orgs"
  add_foreign_key "geo_cohorts", "service_areas"
  add_foreign_key "hra_surveys", "patients"
  add_foreign_key "insurance_policies", "patients"
  add_foreign_key "insurance_policies", "programs"
  add_foreign_key "insurances", "patients", on_delete: :cascade
  add_foreign_key "kustomer_csv_upload_failures", "kustomer_csv_uploads"
  add_foreign_key "kustomer_csv_uploads", "demand_partners"
  add_foreign_key "kustomer_csv_uploads", "users"
  add_foreign_key "orders", "appointments"
  add_foreign_key "orders", "demand_partners"
  add_foreign_key "orders", "patients"
  add_foreign_key "outreach_campaign_contacts", "outreach_campaigns"
  add_foreign_key "outreach_campaigns", "programs"
  add_foreign_key "patient_geos", "geo_cohorts"
  add_foreign_key "patient_geos", "patients"
  add_foreign_key "patient_geos", "programs"
  add_foreign_key "patient_geos", "service_areas"
  add_foreign_key "patients", "demand_partners"
  add_foreign_key "patients", "primary_care_physicians"
  add_foreign_key "pharmacies", "patients", on_delete: :cascade
  add_foreign_key "programs", "demand_partners"
  add_foreign_key "provider_preferences", "field_providers"
  add_foreign_key "provider_preferences", "patients"
  add_foreign_key "redox_clinical_summaries", "demand_partners"
  add_foreign_key "redox_clinical_summaries", "orders"
  add_foreign_key "redox_clinical_summaries", "patients"
  add_foreign_key "redox_destinations", "demand_partners"
  add_foreign_key "redox_pdf_uploads", "appointments"
  add_foreign_key "redox_pdf_uploads", "orders"
  add_foreign_key "redox_pdf_uploads", "patients"
  add_foreign_key "scheduler_logs", "patients"
  add_foreign_key "scheduler_logs", "service_areas"
  add_foreign_key "scheduler_logs", "users"
  add_foreign_key "scheduler_logs", "visits"
  add_foreign_key "service_requests", "patients"
  add_foreign_key "service_requests", "programs"
  add_foreign_key "service_requests", "services"
  add_foreign_key "sms_templates", "demand_partners"
  add_foreign_key "surveys", "appointments"
  add_foreign_key "surveys", "patients"
  add_foreign_key "taggings", "tags"
  add_foreign_key "uploaded_data_imports", "demand_partners"
  add_foreign_key "uploaded_data_imports", "users"
  add_foreign_key "visit_events", "field_providers"
  add_foreign_key "visit_events", "visits"
  add_foreign_key "visit_request_services", "services"
  add_foreign_key "visit_request_services", "visit_requests"
  add_foreign_key "visit_requests", "patients"
  add_foreign_key "visit_requests", "programs"
  add_foreign_key "visit_requests", "users", column: "creator_id"
  add_foreign_key "visit_resource_requirements", "visit_types"
  add_foreign_key "visit_resources", "field_providers"
  add_foreign_key "visit_resources", "visits"
  add_foreign_key "visit_types", "programs"
  add_foreign_key "visits", "cancel_codes"
  add_foreign_key "visits", "field_providers"
  add_foreign_key "visits", "patients"
  add_foreign_key "visits", "programs"
  add_foreign_key "visits", "visit_requests"
  add_foreign_key "visits", "visit_types"
  add_foreign_key "visits", "visits", column: "next_linked_visit_id"
  add_foreign_key "visits", "visits", column: "original_visit_id"
  add_foreign_key "visits", "visits", column: "previous_linked_visit_id"
  add_foreign_key "work_sessions", "field_providers"
  add_foreign_key "work_sessions", "visits"
end
