# typed: true
# frozen_string_literal: true

module Alayacare
  class PushVisit < ApiClient
    def initialize(mode, visit)
      super()

      @visit = visit
      @mode = mode
    end

    def call
      # Don't push v2 program visits to AC
      return OpenStruct.new(success?: true) if @visit.program&.v2?

      @existing_patient_result = @api.get("patients/clients/by_id/#{@visit.patient.medical_record_number}")

      Alayacare::ClientCreateOrUpdateService.call(@visit.patient, ["all"]) unless @existing_patient_result.success?

      create_or_update_visit
    end

    def create_or_update_visit
      body = {
        client_id:            @visit.patient.medical_record_number,
        start_at:             @visit.start_time,
        end_at:               @visit.end_time,
        employee_id:          @visit.field_provider&.external_id&.to_s,
        service_instructions: @visit.service_instructions || "",
        cancelled:            @visit.canceled,
        cancel_code_id:       @visit.cancel_code&.alayacare_id
      }

      # TODO: check for race condition!

      recreate_visit_result = recreate_visit_if_services_changed
      return recreate_visit_result unless recreate_visit_result.success?

      if @mode == :create
        # Add service create only
        service_response = add_service
        return service_response unless service_response.success?

        body[:alayacare_service_id] = service_response.payload

        body[:visit_id] = @visit.external_id
        @api.post("scheduler/visits", body)
      else
        body[:service_code_id] = @visit.visit_type.alayacare_id if @visit.visit_type_id_changed?

        @api.put("scheduler/visits/by_id/#{@visit.external_id}", body)
      end
    end

    private

    def recreate_visit_if_services_changed
      # Recreate visit if services added or removed or if ids changed.
      services_modified = @visit.services_modified || @visit.services.any?(&:alayacare_id_changed?)
      should_recreate_visit = services_modified && @mode == :update
      return OpenStruct.new(success?: true) unless should_recreate_visit

      if @visit.start_time < Time.zone.now
        return OpenStruct.new(success?: false, error: "Can not change services on visit that has already started.")
      end

      # set mode to create to make new visit with services after canceling old one
      @mode = :create

      # Cancel existing visit and remove external_id to avoid conflicts.
      system_cancellation_prefix = "SYSTEM CANCELATION"
      cancel_reason = CancelCode.where("code LIKE :prefix", prefix: "#{system_cancellation_prefix}%").first

      if cancel_reason.blank?
        return OpenStruct.new(success?: false,
                              error:    "Could not find system cancelation reason")
      end

      cancel_body = {visit_id:       nil,
                     cancelled:      true,
                     cancel_code_id: cancel_reason.alayacare_id}
      @api.put("scheduler/visits/by_id/#{@visit.external_id}", cancel_body)
    end

    def add_service
      service_code_id = @visit.visit_type.alayacare_id
      form_ids = @visit.services.map(&:alayacare_id).sort.uniq
      ac_service_name = "MA Service - #{form_ids.join(',')}"

      # Search for existing service
      result = @api.get("scheduler/services?client_id=#{@visit.patient.medical_record_number}")
      if result.success?
        body = JSON.parse(result.body)
        body["items"].each do |item|
          if item["service_name"] == ac_service_name && 
             item["alayacare_service_code_id"].to_s == service_code_id
            return OpenStruct.new({success?: true,
                                   payload:  item["alayacare_service_id"]})
          end
        end
      end

      # create new service
      service_body = {
        client:                 {
          client_id: @visit.patient.medical_record_number
        },
        service_code_id:        service_code_id,
        name:                   ac_service_name,
        form_ids:               form_ids,
        funding_methodology:    "single_funder", # required but always the same
        guid_funder_breakdowns: [{funder_id: 1, is_primary: 1, percentage: 100}] # required but always the same
      }

      service_result = @api.post("scheduler/services", service_body)

      if service_result.success?
        body = JSON.parse(service_result.body)

        unless body["id"]
          return OpenStruct.new({success?: false,
                                 error:    "service_id is missing, please contact admins."})
        end

        return OpenStruct.new({success?: true, payload: body["id"]})
      end
      service_result
    end
  end
end
