# frozen_string_literal: true

module Alayacare
  class BackfillVisits < ::ApplicationService
    def initialize(pending_job_id, start_date:, end_date:, dry_run: true)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
      @dry_run = dry_run
      @start_date = start_date
      @end_date = end_date
      @start_datetime = CGI.escape(start_date.beginning_of_day.iso8601)
      @end_datetime = CGI.escape(end_date.end_of_day.iso8601)
      @pending_job_id = pending_job_id

      @run_id = SecureRandom.uuid

      @errors = []
    end

    def call
      # Update visit types just in case
      Alayacare::PullExternalData.call(VisitType, "scheduler/service_codes", :name)

      log_message("Backfill job for visits #{@start_date}-#{@end_date} in #{@dry_run ? 'dry run' : 'create'} mode")
      response = GetPaginatedIndex.call(@api,
                                        "scheduler/visits?start_date_from=#{@start_datetime}&start_date_to=#{@end_datetime}")
      return OpenStruct.new(success?: false, error: "Could not fetch visits") unless response.success?

      log_message("Fetched #{response.payload.length} visits")

      total = response.payload.length
      created = 0
      matched = 0
      skipped = 0
      updated = 0
      ac_updated = 0
      ma_updated = 0

      response.payload.each do |visit|
        if should_skip? visit
          skipped += 1
          next
        end

        medarrive_visit = Visit.find_by(external_id: visit["visit_id"])

        if medarrive_visit.blank?
          created += 1
          create_result = create_visit_from_alayacare(visit)

          unless create_result.success?
            msg = "Failed to create visit #{visit['visit_id']} at #{visit['start_at']}: #{create_result.error}"
            @errors << msg
            log_message(msg)
            next
          end
          medarrive_visit = create_result.payload
        else
          medarrive_visit.skip_push_to_external = true
          if visit_mismatch(medarrive_visit, visit)
            updated += 1
            update_result = update_visit_from_alayacare(medarrive_visit, visit)
            unless update_result.success?
              msg = "Failed to update visit #{visit['visit_id']} at #{visit['start_at']}: #{update_result.error}"
              @errors << msg
              log_message(msg)
              next
            end
          else
            matched += 1
            # updated status still counts as matched
            if medarrive_visit.alayacare_status != visit["status"] && !@dry_run
              medarrive_visit.update(alayacare_status: visit["status"])
            end
          end
        end

        # We will either push external ids to AC or pull to MA depending on the format we find on AC
        if visit["visit_id"]&.starts_with?("Visit")
          # AC already has generated external_id, copy it's value locally if needed.
          unless medarrive_visit.external_id == visit["visit_id"]
            ma_updated += 1
            medarrive_visit.update(external_id: visit["visit_id"]) unless @dry_run

            @errors << medarrive_visit.errors.full_messages.to_sentence if medarrive_visit.errors.full_messages.present?
          end
        else
          # AC has legacy or no external id.  Push local id to AC.
          ac_updated += 1
          unless @dry_run
            response = @api.put("scheduler/visits/#{visit['alayacare_visit_id']}",
                                {"visit_id" => medarrive_visit.external_id})

            unless response.success?
              msg = "Failed to update id to #{medarrive_visit.external_id} for #{visit} due to #{response.body}"
              @errors << msg
              log_message(msg)
            end
          end
        end
      end

      msg = "Finished.  Total: #{total}, Created: #{created}, Matched: #{matched}, Updated: #{updated}, skipped: #{skipped} | ID updated in MA: #{ma_updated}, ID updated in AC: #{ac_updated} | error count: #{@errors.length}"
      log_message(msg)
      record_results(msg)

      if @errors.blank?
        OpenStruct.new(success?: true, message: msg)
      else
        OpenStruct.new(success?: false, error: "#{msg}, errors: #{@errors.join(' ')}")
      end
    end

    def should_skip?(visit)
      log_missing_field_provider_id(visit) if visit["employee_id"].blank? && visit["alayacare_employee_id"].present?

      visit["employee_id"].blank? || visit["client_id"].blank? || is_system_cancelation?(visit)
    end

    def log_missing_field_provider_id(visit)
      msg = "Improperly set up field provider missing employee id.  Internal id: #{visit['alayacare_employee_id']}"

      result = @api.get("employees/employees/#{visit['alayacare_employee_id']}")
      if result.success?
        begin
          body = JSON.parse(result.body)
          demographics = body["demographics"]
          msg += ", Name: #{demographics['first_name']} #{demographics['last_name']}, Email: #{demographics['email']}"
        rescue StandardError => e
          Sentry.capture_exception(e)
        end
      end

      @errors << msg
      log_message(msg)
    end

    def visit_mismatch(medarrive_visit, visit)
      [
        medarrive_visit.start_time != Time.zone.parse(visit["start_at"]),
        medarrive_visit.end_time != Time.zone.parse(visit["end_at"]),
        medarrive_visit.field_provider&.external_id != visit["employee_id"],
        medarrive_visit.canceled != visit["cancelled"],
        medarrive_visit&.cancel_code&.code != visit.dig("cancel_code", "code")
      ].any?
    end

    def update_visit_from_alayacare(medarrive_visit, visit)
      fp_result = find_or_create_fp(visit["employee_id"])
      return fp_result unless fp_result.success?

      updates = {
        start_time:           Time.zone.parse(visit["start_at"]),
        end_time:             Time.zone.parse(visit["end_at"]),
        field_provider:       fp_result.payload,
        canceled:             visit["cancelled"],
        service_instructions: visit["service_instructions"],
        alayacare_status:     visit["status"]
      }

      medarrive_visit.assign_attributes(updates)

      if medarrive_visit.canceled
        cancel_code = CancelCode.find_by(code: visit.dig("cancel_code", "code"))
        if cancel_code.blank?
          return OpenStruct.new(success?: false, error: "Can't find cancel code #{visit['cancel_code']['code']}")
        end

        medarrive_visit.cancel_code = cancel_code
      end

      medarrive_visit.validate # make sure there is an external_id even if not saving
      medarrive_visit.save unless @dry_run

      unless medarrive_visit.errors.empty?
        return OpenStruct.new(success?: false, error: medarrive_visit.errors.full_messages.to_sentence)
      end

      OpenStruct.new(success?: true, payload: medarrive_visit)
    end

    def create_visit_from_alayacare(visit)
      # visit type
      visit_type = VisitType.find_by(alayacare_id: visit["service_code_id"])
      if visit_type.blank?
        err = "Can't find visit type with alayacare_id #{visit['service_code_id']}"
        return OpenStruct.new(success?: false, error: err)
      end

      # patient
      patient_result = find_or_create_patient(visit["client_id"], visit_type)
      return patient_result unless patient_result.success?

      patient = patient_result.payload

      # field provider
      fp_result = find_or_create_fp(visit["employee_id"])
      return fp_result unless fp_result.success?

      fp = fp_result.payload

      # Find program from visit type or patient
      program = if visit_type.programs.count == 1
                  visit_type.programs.first
                elsif patient.programs.count == 1
                  patient.programs.first
                elsif EnvHelper.env_or_nil("HOST_ENV") != "prod"
                  Program.find_or_create_by(name:                      "Catch-all",
                                            demand_partner:            DemandPartner.first,
                                            alayacare_service_code_id: "")
                end

      unless program.present? && program.persisted?
        err = "Can't find determine program from visit type #{visit_type.name} or patient #{patient.full_name}"
        err += " program error: #{program&.errors&.full_messages&.to_sentence}" if program.present?
        return OpenStruct.new(success?: false, error: err)
      end

      medarrive_visit = Visit.new(
        start_time:           visit["start_at"],
        end_time:             visit["end_at"],
        patient:              patient,
        field_provider:       fp,
        visit_type:           visit_type,
        canceled:             visit["cancelled"],
        program:              program,
        service_instructions: visit["service_instructions"],
        alayacare_status:     visit["status"]
      )

      if medarrive_visit.canceled
        cancel_code = CancelCode.find_by(code: visit.dig("cancel_code", "code"))
        if cancel_code.blank?
          return OpenStruct.new(success?: false, error: "Can't find cancel code #{visit['cancel_code']['code']}")
        end

        medarrive_visit.cancel_code = cancel_code
      end

      medarrive_visit.validate # make sure there is an external_id even if not saving
      medarrive_visit.skip_push_to_external = true
      medarrive_visit.save unless @dry_run

      unless medarrive_visit.errors.empty?
        return OpenStruct.new(success?: false, error: medarrive_visit.errors.full_messages.to_sentence)
      end

      OpenStruct.new(success?: true, payload: medarrive_visit)
    end

    def find_or_create_patient(patient_id, visit_type)
      # return existing patient
      patient = ::Patient.find_by(medical_record_number: patient_id)
      return OpenStruct.new(success?: true, payload: patient) if patient.present?

      # get patient from AC
      result = @api.get("patients/clients/by_id/#{patient_id}")
      unless result.success?
        return OpenStruct.new(success?: false, error: "Could not fetch patient #{patient_id}: #{result.body}")
      end

      patient = JSON.parse(result.body)
      demo = patient["demographics"]

      # check for demand partner
      demand_partner = DemandPartner.where(name: patient["groups"].map {|group| group["name"] }).first
      if demand_partner.blank?
        return OpenStruct.new(success?: false, error: "Could not find demand partner from #{patient['groups']}")
      end

      sex = case demo["gender"]
            when "M"
              "Male"
            when "F"
              "Female"
            else
              "Unknown"
            end

      # create patient if not found
      medarrive_patient = ::Patient.new(
        medical_record_number: patient_id,
        first_name:            demo["first_name"],
        last_name:             demo["last_name"],
        sex:                   sex,
        date_of_birth:         demo["birthday"] || nil,
        phone_number:          demo["phone_main"] || demo["phone_personal"] || demo["phone_other"],
        demand_partner:        demand_partner
      )

      medarrive_patient.programs << visit_type.programs.first if visit_type.programs.count == 1

      add_user(medarrive_patient, demo["email"])
      add_address(medarrive_patient, demo)

      if @dry_run
        medarrive_patient.validate
        OpenStruct.new(success?: true, payload: medarrive_patient)
      elsif medarrive_patient.save
        OpenStruct.new(success?: true, payload: medarrive_patient)
      else
        OpenStruct.new(success?: false, error: medarrive_patient.errors.full_messages.to_sentence)
      end
    end

    def find_or_create_fp(fp_id)
      # return existing fp
      fp = FieldProvider.find_by(external_id: fp_id)
      return OpenStruct.new(success?: true, payload: fp) if fp.present?

      # get fp from AC
      result = @api.get("employees/employees/by_id/#{fp_id}")
      unless result.success?
        return OpenStruct.new(success?: false, error: "Could not fetch fp #{fp_id}: #{result.body}")
      end

      fp = JSON.parse(result.body)
      demo = fp["demographics"]

      # create fp if not found
      medarrive_fp = FieldProvider.new(
        external_id: fp_id,
        first_name:  demo["first_name"],
        last_name:   demo["last_name"],
        phone:       demo["phone_main"] || demo["phone_personal"] || demo["phone_other"],
        field_org:   FieldOrg.find_or_initialize_by(name: "dummy_org")
      )

      add_user(medarrive_fp, demo["email"])
      add_address(medarrive_fp, demo)

      medarrive_fp.skip_push_to_external = true

      if @dry_run
        medarrive_fp.validate
        OpenStruct.new(success?: true, payload: medarrive_fp)
      elsif medarrive_fp.save
        OpenStruct.new(success?: true, payload: medarrive_fp)
      else
        OpenStruct.new(success?: false, error: medarrive_fp.errors.full_messages.to_sentence)
      end
    end

    def add_user(ma_obj, email)
      if email.present?
        user = User.find_or_initialize_by(email: email)
        user.assign_random_password
        user.skip_push_to_external = true
        ma_obj.user = user
      end
    end

    def add_address(ma_obj, demo)
      if demo["address"].present?
        address_hash = {
          address_line_one: demo["address"],
          address_line_two: demo["address_suite"],
          city:             demo["city"],
          state:            demo["state"],
          zipcode:          demo["zip"],
          longitude:        demo.dig("location", "lon"),
          latitude:         demo.dig("location", "lat")
        }
        ma_obj.build_address(address_hash)
      end
    end

    def is_system_cancelation?(visit)
      visit.dig("cancel_code", "code")&.start_with? "SYSTEM CANCELATION"
    end

    def log_message(msg)
      msg = "#{@run_id} #{msg}"
      # To actually show up in data dog "Rails.logger.info" doesn't work.
      p msg
    end

    def record_results(msg)
      status = @errors.present? ? "failed" : "succeeded"

      pending_job = BackgroundJobResult.find_by(id: @pending_job_id)
      return if pending_job.blank?

      pending_job.update(
        status:     status,
        message:    msg,
        error_list: @errors || nil
      )
    end
  end
end
