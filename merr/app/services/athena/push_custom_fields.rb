# typed: true
# frozen_string_literal: true

module Athena
  class PushCustomFields < ApiClient
    def initialize(object, assignments, department_id)
      super()
      @object = object
      @assignments = assignments # e.g. {"MedArrive ID" => "test"}

      @department_id = department_id

      @athena_custom_field_ids = Rails.cache.fetch("athena_custom_field_ids") do
        AthenaCustomField.all.map {|f| [f.name, f.athena_id]}.to_h
      end
    end

    def call
      athena_formatted_assignments = []

      @assignments.each do |key, value|
        custom_field_athena_id = @athena_custom_field_ids[key]

        if custom_field_athena_id.blank?
          Sentry.capture_message("Custom field not configured: #{key}")
          next
        end

        athena_formatted_assignments << {
          customfieldid:    custom_field_athena_id.to_s,
          customfieldvalue: value.to_s
        }
      end

      put_body = {customfields: athena_formatted_assignments.to_json}

      if @object.instance_of?(Visit)
        @api.put("appointments/#{@object.athena_id}/customfields", put_body)
      else
        put_body[:departmentid] = @department_id
        @api.put("patients/#{@object.athena_id}/customfields", put_body)
      end
    end
  end
end
