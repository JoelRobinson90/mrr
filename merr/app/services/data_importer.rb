# frozen_string_literal: true

# typed: true

class DataImporter < ApplicationService
  require "csv"
  require "set"

  SERVICE_DELIMITER = "|"

  def initialize(file, type, demand_partner_id, import_to, update_only, pending_job_id = nil)
    @type = type
    @demand_partner_id = demand_partner_id
    @demand_partner_name = DemandPartner.find(id = demand_partner_id.to_s).name
    @file = file
    @rows = CSV.read(file, headers: true)
    @successes = 0
    @failures = 0
    @import_to = import_to.downcase
    @update_only = update_only
    @expected_fields = %w[first_name last_name middle_initial consent_to_text date_of_birth phone_number secondary_phone_number medical_record_number
                          sex gender preferred_language needs_hra_survey preferred_pronouns race ethnicity primary_risk_category contact_email datalake_id].freeze
    @present_expected_fields = []
    @demand_partner_custom_fields = DemandPartnerCustomField.all
    @v2_demand_partner_custom_fields, @v1_demand_partner_custom_fields = @demand_partner_custom_fields.partition(&:v2?)

    @pending_job_id = pending_job_id

    if @type == "alayacare"
      # reset cache for service codes and groups
      Rails.cache.delete("ac_service_codes")
      Rails.cache.delete("ac_demand_partner_groups")
    end
  end

  def call
    return error_result("No data received") if @rows.blank?

    case @type
    when "medarrive", "kustomer", "alayacare"
      result = medarrive_create_patients
    else
      return error_result("Type not found")
    end
    if result.success?
      OpenStruct.new({success?: true,
                      message:  "Total: #{@rows.length} Succeeded: #{@successes} Failed: #{@failures}"})
    else
      result
    end
  end

  def scan_parse_sex(sex)
    case sex
    when "M"
      "Male"
    when "F"
      "Female"
    else
      "Unknown"
    end
  end

  def check_for_dups(label, array)
    # Turn array into a set so there are no duplicates and compare size with
    # the full list. If the set smaller, there are dupes. Then do this slow operation
    # https://ruby-doc.org/stdlib-2.7.1/libdoc/set/rdoc/Set.html
    set = array.uniq

    if set.length < array.length
      duplicates = array.group_by {|e| e }.select {|_k, v| v.size > 1 }.map(&:first)
      return "Duplicate #{label}: #{duplicates.to_sentence}"
    end
    false
  end

  def check_for_invalid_lookup_keys(label, patient_hash, array)
    if @update_only && array.length != patient_hash.length && @type === "medarrive"
      keys_without_matches = array.reject do |x|
        patient_hash.include? x
      end

      return "Update only mode enabled, but could not find patients with #{label}: #{keys_without_matches}"
    end
    false
  end

  def medarrive_create_patients
    unique_demand_partners = @rows.map {|r| r["demand_partner"] }.uniq.compact

    return error_result("please include demand partner in the csv") if unique_demand_partners.length.zero?

    return error_result("multiple demand partners in sheet") if unique_demand_partners.length > 1

    if @demand_partner_name.downcase != unique_demand_partners[0].downcase
      return error_result("Demand Partner does not match")
    end

    patients = []
    kustomer_patients = []
    Rails.logger.info("Importing #{@type} file with #{@rows.length} rows")

    address_fields = %w[address_line_one address_line_two city county state zipcode latitude longitude].freeze

    insurance_fields = %w[insurance_package_id policy_holder_first_name policy_holder_last_name policy_holder_sex
                          relationship_to_insured_id insurance_id_number insurance_sequence_number].freeze

    # These fields are expected, but not saved directly to the patient object.
    extra_fields = %w[service_area geo_cohort service_requests termed termed_date]

    no_program = @rows.filter {|r| r["program"].nil? }
    return error_result("Program is a required field") if no_program.length.positive?

    # Get list of distinct service areas
    service_area_names = @rows.map {|r| r["service_area"].presence }.compact
    geo_cohort_names = @rows.map {|r| r["geo_cohort"].presence }.compact
    if service_area_names.length != geo_cohort_names.length
      return error_result("if service_area is present, then geo_cohort is required and vice versa")
    end

    # Pre-create any needed service areas
    service_areas_by_name = {}
    service_area_names.each do |service_area_name|
      service_areas_by_name[service_area_name] = ServiceArea.find_or_create_by(name: service_area_name)
    end

    # Pre-create any needed geo cohorts
    geo_cohorts_by_name = {}
    @rows.each do |row|
      service_area = service_areas_by_name[row["service_area"]]
      geo_cohort_name = row["geo_cohort"]
      if geo_cohorts_by_name[geo_cohort_name].blank?
        geo_cohort = GeoCohort.find_or_create_by(name: geo_cohort_name, service_area: service_area)
        geo_cohorts_by_name[geo_cohort_name] = geo_cohort
      end
    end

    # Check for duplicates
    # This is fine, not great on the speed. We should hold on to the id_list and call it
    # medical_record_number list so we can use it in the next step
    medical_record_numbers = @rows.map {|r| r["medical_record_number"] }.compact
    postgres_ids = @rows.map {|r| r["postgres_id"] }.compact_blank
    use_postgres_ids = postgres_ids.present?
    unique_programs = @rows.map {|r| r["program"] }.uniq.compact

    program_lookup_by_name = Program.where(name: unique_programs).index_by(&:name)
    programs_that_exist = Program.where(name: unique_programs).pluck(:name)
    programs_that_dont_exist = unique_programs - programs_that_exist

    if programs_that_dont_exist.count.positive?
      return error_result("Progam(s) #{programs_that_dont_exist.join(', ')} missing")
    end

    # Find all the requested services and make sure they are recognized
    unique_service_names = Set.new
    @rows.pluck("service_requests").compact.each do |service_list|
      unique_service_names.merge(service_list.split(SERVICE_DELIMITER))
    end
    services_that_exist = Service.where(name: unique_service_names)
    services_that_dont_exist = unique_service_names - services_that_exist.pluck(:name)

    if services_that_dont_exist.count.positive?
      return error_result("Service(s) #{services_that_dont_exist.to_a.join(', ')} missing")
    end

    # make a hash of services to streamline lookups for each patient.
    service_lookup_by_name = services_that_exist.index_by(&:name)

    patient_hash = if use_postgres_ids
                     existing_patients = Patient.where(id:                postgres_ids,
                                                       demand_partner_id: @demand_partner_id)
                     existing_patients.index_by(&:id)
                   else
                     existing_patients = Patient.where(medical_record_number: medical_record_numbers,
                                                       demand_partner_id:     @demand_partner_id)
                     existing_patients.index_by(&:medical_record_number)
                   end

    dup_error = if use_postgres_ids
                  check_for_dups("postgres_ids", postgres_ids)
                else
                  check_for_dups("MRNs", medical_record_numbers)
                end
    return error_result(dup_error) if dup_error.present?

    missing_error = if use_postgres_ids
                      check_for_invalid_lookup_keys("postgres_ids", patient_hash, postgres_ids)
                    else
                      check_for_invalid_lookup_keys("MRNs", patient_hash, medical_record_numbers)
                    end
    return error_result(missing_error) if missing_error.present?

    @rows.each_with_index do |csv_row, i|
      address_line_values_absent = []

      if i === 0
        csv_row.to_h.each_key do |header|
          if @expected_fields.include?(header) || address_fields.include?(header) || insurance_fields.include?(header)
            @present_expected_fields.push(header)
          end

          next unless %w[address_line_one city state zipcode].include?(header)

          address_line_values_absent = @rows.filter do |r|
            r["city"].nil? || r["state"].nil? || r["address_line_one"].nil? || r["zipcode"].nil?
          end

          if address_line_values_absent.length.positive?
            @failures += 1
            return error_result("address_line_one, city, state, and zipcode are required fields")
          end
        end

      end

      row = csv_row.to_h.transform_keys {|key| key.to_s.downcase }

      patient = Patient.new

      if row["medical_record_number"].blank?
        @failures += 1
        return error_result("Medical Record Number is a required column")
      end

      mrn = row["medical_record_number"]
      postgres_id = row["postgres_id"]
      existing_patient = patient_hash[mrn] || patient_hash[postgres_id]
      patient = existing_patient if existing_patient.present?

      @expected_fields.each do |field|
        # Don't override fields not present in the CSV
        next if row[field].blank?

        value = row[field].strip

        if value.downcase == "***remove***"
          patient[field] = nil
          next
        end

        patient[field] = case field.downcase
                         when "date_of_birth"
                           parsed_date(value)
                         when "preferred_language"
                           parsed_preferred_language(value)
                         when "sex"
                           parsed_sex(value)
                         when "needs_hra_survey"
                           parsed_needs_hra_survey(value)
                         when "gender"
                           value.titleize
                         when "preferred_pronouns"
                           value.downcase
                         when "race"
                           parsed_race(value.downcase)
                         when "ethnicity"
                           parsed_ethnicity(value.downcase)
                         else
                           value
                         end
      end

      # save address
      if row["address_line_one"].present?
        address_hash = row.filter {|k| address_fields.include? k }
        if patient.address.blank?
          # Add new address
          patient.build_address(address_hash)
        else
          # Update existing address atomically when patient is saved
          patient.address.assign_attributes(address_hash)
        end

        patient.address.skip_geocoding = true if address_hash["latitude"] && address_hash["longitude"]
      end

      # Create an admin note containing any keys we haven't saved
      remaining_keys = (row.keys - (@expected_fields + address_fields + insurance_fields + extra_fields))
      if remaining_keys
        notes = []
        remaining_keys.each do |note_key|
          notes << "#{note_key.humanize}: #{row[note_key]}" if row[note_key].present?
        end

        content = notes.join("\n")
        # Check if identical note already exists to preserve idempotent runs
        if content.present? && patient.admin_notes.where(content: content).blank?
          patient.admin_notes.build(creator_id: @current_user_id, content: content)
        end
      end

      patient.demand_partner_id = @demand_partner_id if patient.demand_partner_id.blank?
      
      selected_program = program_lookup_by_name[row["program"]]

      matching_group_in_ac = Alayacare::ClientCreateOrUpdateService.new(patient, []).fetch_groups
      if !selected_program.v2?
        return error_result("#{@demand_partner_name} does not exist in AC") if matching_group_in_ac.length.zero?
      end

      existing_program_mapping = PatientProgram.find_by(patient_id: patient.id,
                                                        program_id: selected_program.id)

      patient.patient_programs_attributes = form_patient_program_attributes(patient,
                                                                            selected_program,
                                                                            existing_program_mapping)

      service_name_list = row["service_requests"]&.split(SERVICE_DELIMITER) || []
      service_requests = service_name_list.map do |service_name|
        service = service_lookup_by_name[service_name]
        ServiceRequest.find_or_initialize_by(service: service,
                                             patient: patient,
                                             program: selected_program)
      end

      patient.service_requests << service_requests if service_requests.present?

      if row["service_area"].present? != row["geo_cohort"].present?
        @failures += 1
        return error_result("service_area and geo_cohort must both be present or both be absent")
      end

      # save insurance if any fields present
      unless (row.keys & insurance_fields).empty?
        insurance_hash = row.slice(*insurance_fields)
        insurance_hash["program"] = selected_program
        if patient.persisted?
          # This only works for existing patients for some unknown reason
          patient.insurance_policies << InsurancePolicy.new(insurance_hash)
        else
          # Hacky workaround for new patients
          patient.build_latest_insurance_policy(insurance_hash)
        end
      end

      if row["service_area"].present?
        service_area = service_areas_by_name[row["service_area"]]
        geo_cohort = geo_cohorts_by_name[row["geo_cohort"]]

        # TODO: It would be nice if we could do one query for all patient geos and filter.
        existing_patient_geo = PatientGeo.find_by(patient: patient, program: selected_program)

        if existing_patient_geo.present?
          if existing_patient_geo.service_area_id != service_area.id
            # It would be nice if this were saved with the patient,
            # but it is a corner case.
            existing_patient_geo.update(service_area: service_area, geo_cohort: geo_cohort)
          end
        else
          patient.build_patient_geo(service_area: service_area,
                                    geo_cohort:   geo_cohort,
                                    program:      selected_program)
        end
      end

      # Process termed patients
      if parse_yes_no(row["termed"])
        # Run now or after patient save?
        CancelTermedPatientVisits.delay.call(patient)
        patient.patient_programs_attributes.first.attributes = {
          status:           "Patient Dismissed",
          status_date:      parsed_date(row["termed_date"]),
          dismissal_reason: "Insurance Termed or Dual Coverage"
        }
      end

      if push_to_alayacare?
        patient.ehr_custom_import_attributes = {}
        @v1_demand_partner_custom_fields.each do |field_mapping|
          next if row[field_mapping.csv_column_name].blank?

          value = row[field_mapping.csv_column_name].strip
          parsed_value = field_mapping.data_type === "boolean" ? parse_yes_no(value) : value

          patient.ehr_custom_import_attributes[field_mapping.ehr_field_name] = parsed_value
        end
      end

      if save_local?
        patient.custom_field_responses_attributes = {}
        custom_field_responses = []
        fields = selected_program.v2? ? @v2_demand_partner_custom_fields : @v1_demand_partner_custom_fields

        fields.each do |e|
          next unless e.demand_partner_id.nil? || e.demand_partner_id === patient.demand_partner_id

          custom_field_response = nil

          next if row[e.csv_column_name].blank?

          # Scope custom field response by program for v2 only (for backwards compatibility)
          response_program_id = selected_program.v2? ? selected_program.id : nil
          existing_custom_field_response = CustomFieldResponse.find_by(patient_id:                     patient.id,
                                                                       program_id:                     response_program_id,
                                                                       demand_partner_custom_field_id: e.id)

          custom_field_response = existing_custom_field_response || CustomFieldResponse.new

          value = row[e.csv_column_name].strip
          custom_field_response.value = value
          custom_field_response.demand_partner_custom_field_id = e.id
          custom_field_response.patient_id = patient.id
          custom_field_response.program_id = response_program_id
          custom_field_responses << custom_field_response
          patient.custom_field_responses_attributes = custom_field_responses
        end
      end

      # Attach any custom v2 CRM fields to PatientProgram
      crm_fields = {}
      @v2_demand_partner_custom_fields.each do |field|
        next if field.crm_field_name.blank?
        next if row[field.csv_column_name].blank?

        value = row[field.csv_column_name].strip
        crm_fields[field.crm_field_name.to_sym] = value
      end

      # PatientProgram is the base model for our V2 CRM (aka Salesforce)
      # Custom fields are attached to this model and sent to CRM on save
      patient.patient_programs_attributes.first.crm_custom_fields = crm_fields

      # TODO: collapse kustomer_patient back down to patient and merge with above block.
      if push_to_kustomer?(selected_program)
        kustomer_patient = patient.attributes
        kustomer_patient["name"] = patient.full_name
        kustomer_patient["dob"] = patient.date_of_birth.in_time_zone.to_datetime if patient.date_of_birth
        kustomer_patient["address"] = patient.address if patient.address

        # If we haven't already saved the connection between this patient and this program
        # (so the program won't show up in patient.programs), make sure we include the program
        # in the programs string we're sending to Kustomer.  If we have already saved it, it's
        # included in patient.programs, and we can just send what we already have.
        programs_str = if existing_program_mapping.nil? && patient.programs_string.length.positive?
                         patient.programs_string + ", #{selected_program[:name]}"
                       elsif patient.programs_string.length.zero?
                         selected_program[:name]
                       else
                         patient.programs_string
                       end

        kustomer_patient[:programs] = programs_str

        @v1_demand_partner_custom_fields.each do |e|
          next if row[e.csv_column_name].blank?

          value = row[e.csv_column_name].strip
          kustomer_patient[e.csv_column_name] = value
        end

        kustomer_patients << kustomer_patient
      end

      patients << patient
    end

    # post to Kustomer and get/return response openstruct for kustomer as applicable
    return organize_and_save_kustomer_data(kustomer_patients) if push_to_kustomer?

    # post to Kustomer and get/return response openstruct for kustomer as applicable
    return send_patients_to_alayacare(patients) if push_to_alayacare?

    # save patients if in 'MedArrive' mode
    save_patients(patients)
  end

  # Unused until we allow multi-destination imports again
  def generate_response_to_ui(resp_one, resp_two)
    good = resp_one ? resp_one.success? : true && resp_two.success?

    resp_one = resp_one.message || resp_one.error if resp_one
    clean_resp_two = ""
    clean_resp_two += resp_two ? resp_two.message || resp_two.error : ""

    if good
      return OpenStruct.new({success?: true,
                             message:  "#{resp_one if @import_to != 'medarrive only'} | #{clean_resp_two}"})
    end

    OpenStruct.new({success?: false,
                    error:    "#{if @import_to != 'medarrive only'
                                   "Kustomer Import Response: #{resp_one} | "
                                 end}MedArrive Response: #{clean_resp_two}"})
  end

  def save_patients(patients)
    error_msg = nil

    # Validate in the same loop as save. Exit if error
    ActiveRecord::Base.transaction do
      patients.each_with_index do |patient, i|
        # once patient saves, address saves too, so we can't check for changed attributes to know if geocoding should happen
        # thus, checking needs to happen here and dictate whether the geocoding method gets called at all
        update_lat_long = patient.address&.changed_attributes&.any? && !patient.address&.skip_geocoding

        # Always set this to true to avoid geocoding syncronously
        # if geocoding needs to be done, "update_lat_long" will trigger background save.
        patient.address.skip_geocoding = true if patient.address

        # We don't want to make this delayed job take too long.
        # Each Alayacare update gets it's own delayed job.
        patient.update_alayacare_in_foreground = false

        # bulk save?
        if patient.save
          @successes += 1
          if patient.address && update_lat_long
            # Set skip geocode to false to allow geocode in background
            patient.address.skip_geocoding = false
            # Use low priority (0 is default) to avoid blocking other delayed jobs.
            patient.address.delay(priority: 10).save
          end
          patient.custom_field_responses_attributes.each do |e|
            e.patient_id = patient.id
            e.save
          end
          patient.patient_programs_attributes.each do |e|
            e.patient_id = patient.id
            e.save
          end
        else
          @failures += 1
          error_msg = "Import error on row #{i}: #{patient.errors.full_messages.to_sentence}"
          raise ActiveRecord::Rollback
        end
      end
    end

    if error_msg
      error_result(error_msg)
    else
      record_results
      OpenStruct.new({success?: true, message: "MedArrive import successful"})
    end
  end

  def send_patients_to_alayacare(patients)
    patients.each_with_index do |patient, i|
      resp = Alayacare::ClientCreateOrUpdateService.call(patient, @present_expected_fields, @update_only)
      if resp.success?
        @successes += 1
      else
        @failures += 1
        msg = "Import error on row #{i}: #{resp.error || resp.body}"
        return error_result(msg)
      end
    end

    record_results
    OpenStruct.new({success?: true, message: "Alayacare import successful"})
  end

  def organize_and_save_kustomer_data(patients)
    errors = []
    patients.each_with_index do |p, i|
      custom_attributes = {}
      # homemade rate-limiting to make sure who don't exceed their limits. Limit is 1,000 requests per minute
      sleep(60.seconds) if (i % 300).zero? && i != 0
      custom_attributes["demandPartnerStr"] = @demand_partner_name
      custom_attributes["programsStr"] = p[:programs]

      @v1_demand_partner_custom_fields.each do |field|
        next if p[field.csv_column_name].blank?
        next if field.crm_field_name.blank?

        custom_attributes[field.crm_field_name] =
          field.data_type === "boolean" ? parse_yes_no(p[field.csv_column_name]) : p[field.csv_column_name]
      end

      # I do not love this second "update only" only for Kustomer, but because it was originally built such that import to and
      # operation type are entirely separate, approaching this the other way would have been more complex.
      create_or_update_patient = Kustomer::CreateOrUpdatePatient.new(p, @present_expected_fields, custom_attributes,
                                                                     @update_only)
      resp = create_or_update_patient.call
      resp = JSON.parse(resp["body"]) if resp["body"]

      # stuff errors/successes in table to be displayed on the import page for trouble-shooting
      if resp["error"].present?
        @failures += 1
        errors << "Row #{i} error: #{resp['error']}"
      else
        @successes += 1
      end
    end

    # makes sure we don't ever accidentally green-light something that failed
    # also updates the background job result
    return error_result(errors) if @failures.positive?

    record_results
    OpenStruct.new({success?: true,
                    message:  "Kustomer import successful"})
  end

  def record_results(errors = nil)
    errors = [errors] if errors.is_a?(String)
    msg = "#{@successes}/#{@rows.length} rows imported"
    status = @failures.positive? ? "failed" : "succeeded"

    pending_job = BackgroundJobResult.find_by(id: @pending_job_id)

    if pending_job.present?
      pending_job.update(
        status:     status,
        message:    msg,
        error_list: errors
      )
    else
      BackgroundJobResult.create(
        status:     status,
        job_type:   @import_to,
        label:      @file.respond_to?(:original_filename) ? @file.original_filename : @file.to_s,
        message:    msg,
        error_list: errors
      )
    end
  end

  def error_result(error)
    Rails.logger.error(error)
    record_results(error)
    OpenStruct.new({success?: false, error: error})
  end

  def parsed_preferred_language(language)
    return nil if language.blank?

    d_language = language.downcase

    return "Spanish" if d_language == "espanol"
    return "English" if d_language == "english (default)"

    language.titleize
  end

  def parsed_sex(sex)
    return nil if sex.blank?

    case sex.downcase
    when "m"
      "Male"
    when "f"
      "Female"
    else
      sex
    end
  end

  def parsed_race(race)
    return "American Indian or Alaska Native" if race.include?("indian") || race.include?("native american")
    return "Asian" if race.include?("asian")
    return "Native Hawaiian or Other Pacific Islander" if race.include?("hawaii") || race.include?("pacific")
    return "Black or African-American" if race.include?("black") || race.include?("african")
    return "White" if race.include?("white") || race.include?("caucasian")
    return "Unknown" if race.include?("unknown") || race.include?("undetermined")
    return "Other Race" if race.include?("other")

    race.titleize
  end

  def parsed_ethnicity(ethnicity)
    if (ethnicity.include?("hispanic") || ethnicity.include?("latino")) && ethnicity.exclude?("not")
      return "Hispanic or Latino"
    end
    if ethnicity.include?("not") && (ethnicity.include?("hispanic") || ethnicity.include?("latino"))
      return "Not Hispanic or Latino"
    end
    return "Not Hispanic or Latino" if ethnicity == "no"
    return "Unknown" if ethnicity.include?("unknown")

    ethnicity.titleize
  end

  def parsed_date(date_str)
    return nil if date_str.blank?

    # try international format
    begin
      return Date.strptime(date_str, "%Y-%m-%d")
    rescue Date::Error
    end

    # try American format
    begin
      if date_str.split("/")[-1].length == 4
        return Date.strptime(date_str, "%m/%d/%Y")
      else
        date = Date.strptime(date_str, "%m/%d/%y")
        # Only allow dates in the past
        date = date.prev_year(100) if date > Date.today
        return date
      end
    rescue Date::Error
    end

    nil
  end

  def parsed_needs_hra_survey(value)
    d_value = value.downcase
    return d_value == "y" if d_value == "y"

    d_value == "yes"
  end

  def parse_yes_no(value)
    d_value = value.downcase if value
    return true if d_value === "yes" || d_value === "y"
    return false if d_value === "no" || d_value === "n"

    d_value
  end

  def form_patient_program_attributes(_patient, selected_program, existing_program_mapping)
    patient_program = existing_program_mapping || PatientProgram.new(program_id: selected_program.id)

    [patient_program]
  end

  def save_local?
    @import_to.include?("medarrive")
  end

  def push_to_alayacare?
    @import_to.include?("alayacare")
  end

  def push_to_kustomer?(program = nil)
    return false unless @import_to.include?("kustomer")
    return false if program&.v2?

    true
  end
end
