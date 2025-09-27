# typed: true
# frozen_string_literal: true

module Athena
  class PushVisit < ApiClient
    def initialize(_mode, visit)
      super()
      @mode = visit.athena_id.present? ? :update : :create
      @visit = visit

      @demand_partner = @visit.patient.demand_partner
      athena_department = @demand_partner.get_athena_department(@visit.patient)
      @department_id = athena_department&.athena_id
      @department_timezone = athena_department&.timezone

      @patient_id = @visit.patient.athena_id
      @provider_id = @visit.get_provider_athena_id
      @appointment_type_id = visit.visit_type.athena_id
      @starting_athena_id = @visit.athena_id

      @custom_fields = {
        "MedArrive Visit ID" => @visit.ma_id
      }
    end

    def call
      if !@visit.should_push_to_athena?
        return OpenStruct.new(success?: true) # ignore updates for non-v2 programs
      elsif @appointment_type_id.blank?
        return OpenStruct.new(success?: false, error: "Visit type missing athena_id")
      elsif @provider_id.blank?
        return OpenStruct.new(success?: false, error: "Field provider missing athena_id")
      elsif @department_id.blank? || @department_timezone.blank?
        return OpenStruct.new(success?: false,
                              error:    "Demand Partner #{@demand_partner.name} has no department in timezone #{@visit.patient.address&.timezone}")
      end

      # we may need to create a patient first
      if @patient_id.blank?
        patient_result = PushPatient.call(@visit.patient, @visit.program, department_id: @department_id)
        return patient_result unless patient_result.success?

        @patient_id = patient_result.payload.athena_id
      end

      if @visit.canceled?
        return cancel_visit unless @visit.athena_id.blank?
      else
        if @visit.athena_id.blank?
          return create_visit
        else
          appt_result = fetch_existing_appointment()
          return appt_result unless appt_result.success?

          return reschedule_visit unless details_match(appt_result.payload)
        end
      end

      OpenStruct.new(success?: true)
    end

    def create_visit
      # create appointment slot
      slot_result = create_appointment_slot
      return slot_result unless slot_result.success?

      # create appointment
      result = @api.put("appointments/#{@appointment_id}", body)

      updates = {
        athena_id:             @appointment_id,
        athena_telehealth_url: get_telehealth_link(@appointment_id),
        last_athena_sync:      "Create result: #{result.body}"
      }
      update_visit_attributes(updates)

      custom_fields_result = PushCustomFields.call(@visit, @custom_fields, @department_id)
      return custom_fields_result unless custom_fields_result.success?

      result
    end

    def get_telehealth_link(appointment_id)
      result = @api.get("appointments/#{appointment_id}/nativeathenatelehealthroom")

      return nil unless result.success?

      JSON.parse(result.body)["patienturl"]
    end

    def reschedule_visit
      return create_visit if @visit.athena_id.blank?

      # create new appointment slot
      slot_result = create_appointment_slot
      return slot_result unless slot_result.success?

      # reschedule appointment
      body = reschedule_body(@appointment_id)
      result = @api.put("appointments/#{@visit.athena_id}/reschedule", body)

      updates = {athena_id:             @appointment_id,
                 athena_telehealth_url: get_telehealth_link(@appointment_id),
                 last_athena_sync:      "Reschedule result: #{result.body}"}
      update_visit_attributes(updates)

      # delete the slot
      @api.delete("appointments/#{@starting_athena_id}")

      result
    end

    def cancel_visit
      url = "appointments/#{@visit.athena_id}/cancel"
      result = @api.put(url, cancellation_body)

      # delete athena id from visit since there is no "restore".
      if result.success? && JSON.parse(result.body).dig("status") == "x"
        update_visit_attributes({athena_id: nil, athena_telehealth_url: nil, last_athena_sync: "Cancel result: #{result.body}"})

        # delete the slot
        @api.delete("appointments/#{@starting_athena_id}")
      end

      result
    end

    def fetch_existing_appointment
      result = @api.get("appointments/#{@visit.athena_id}")

      unless result.success?
        return OpenStruct.new(success?: false, error: "Could not fetch appointment #{@visit.athena_id} - #{result.body}")
      end

      appt = JSON.parse(result.body)

      status = appt.dig(0, "appointmentstatus")

      if status == "x"
        return OpenStruct.new(success?: false, error: "Appointment #{@visit.athena_id} canceled in Athena.")
      elsif status == "o"
        return OpenStruct.new(success?: false, error: "Appointment slot #{@visit.athena_id} empty in Athena.")
      end
      
      return OpenStruct.new(success?: true, payload: appt.dig(0))
    end

    def details_match(existing_appt)

      comparisons = {
        appointmentdate:   "date",
        appointmenttime:   "starttime",
        departmentid:      "departmentid",
        providerid:        "providerid",
        appointmenttypeid: "appointmenttypeid"
      }

      visit_details = slot_body

      comparisons.each do |visit_key,appt_key|
        return false if visit_details[visit_key].to_s != existing_appt[appt_key].to_s
      end

      true
    end

    def create_appointment_slot
      slot_result = @api.post("appointments/open", slot_body)
      return slot_result unless slot_result.success?

      slot_json = JSON.parse(slot_result.body)
      @appointment_id = slot_json["appointmentids"].keys[0]

      slot_result
    end

    def update_visit_attributes(attributes)
      if @visit.persisted?
        @visit.paper_trail.update_columns(attributes.stringify_keys)
      else
        @visit.assign_attributes(attributes)
      end
    end

    def slot_body
      time = @visit.start_time.in_time_zone(@department_timezone)
      {
        departmentid:      @department_id,
        providerid:        @provider_id,
        appointmentdate:   time.strftime("%m/%d/%Y"),
        appointmenttime:   time.strftime("%H:%M"),
        appointmenttypeid: @appointment_type_id
      }
    end

    def body
      {
        patientid:                   @patient_id,
        appointmenttypeid:           @appointment_type_id,
        departmentid:                @department_id,
        ignoreschedulablepermission: true,
        nopatientcase:               true
      }
    end

    def cancellation_body
      body = {
        patientid:                   @visit.patient.athena_id,
        ignoreschedulablepermission: true
      }

      if @visit.cancel_code&.athena_id&.present?
        body[:appointmentcancelreasonid] = @visit.cancel_code.athena_id
      else
        body[:cancellationreason] = @visit.cancel_code&.code || ""
      end
      body
    end

    def reschedule_body(appointment_id)
      {
        patientid:                   @patient_id,
        newappointmentid:            appointment_id,
        ignoreschedulablepermission: true
      }
    end
  end
end
