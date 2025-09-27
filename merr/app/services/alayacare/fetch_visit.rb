# typed: true
# frozen_string_literal: true

module Alayacare
  class FetchVisit < ApiClient
    include Routing::Helpers
    def initialize(alayacare_visit_id, internal_visit_id:, include_notes: false)
      super()

      @alayacare_visit_id = alayacare_visit_id
      @internal_visit_id  = internal_visit_id
      @include_notes      = include_notes
    end

    def call
      ma_visit = Visit.find_by(external_id: @internal_visit_id)

      if ma_visit.present?
        visit = {
          id:                   ma_visit.id,
          alayacare_visit_id:   nil,
          field_provider:       {
            id:         ma_visit.id,
            first_name: ma_visit.field_provider.full_name
          },
          start_time:           ma_visit.start_time,
          end_time:             ma_visit.end_time,
          service_code_name:    ma_visit.visit_type&.name,
          canceled:             ma_visit.canceled,
          cancel_reason:        ma_visit.canceled ? ma_visit.cancel_code.code : "",
          services:             ma_visit ? ma_visit.services.map {|s| s.to_builder.attributes! } : [],
          service_instructions: ma_visit.service_instructions,
          local:                ma_visit.present?,
          local_visit_id:       ma_visit.id,
          visit_type_id:        ma_visit.visit_type_id,
          visit_type:           ma_visit.visit_type,
          visit_group:          ma_visit.visit_group,
          program:              ma_visit.program&.to_builder&.attributes!,
          cx_start:             round_time_15(ma_visit.start_time),
          cx_end:               round_time_15(ma_visit.end_time),
          arrival_window_start: ma_visit.arrival_window_start,
          arrival_window_end:   ma_visit.arrival_window_end,
          notes:                remote_visit_notes,
          patient_id:           ma_visit.patient_id,
          external_id:          ma_visit.external_id,
          ma_id:                ma_visit.external_id,
          program_id:           ma_visit.program_id,
          service_ids:          ma_visit.service_ids,
          display_status:       ma_visit.display_status,
        }

        return OpenStruct.new({success?: true, payload: visit})
      end

      return OpenStruct.new({success?: true, payload: nil}) unless @alayacare_visit_id

      ac_visit_response = @api.get("scheduler/visits/#{@alayacare_visit_id}")

      if ac_visit_response.success?
        ac_visit = begin
          JSON.parse(ac_visit_response.body)
        rescue StandardError
          nil
        end
        ac_visit = ac_visit.symbolize_keys if ac_visit.respond_to? :symbolize_keys

        ma_visit = Visit.find_by external_id: @internal_visit_id

        visit = {
          id:                   @internal_visit_id,
          alayacare_visit_id:   ac_visit[:alayacare_visit_id],
          field_provider:       {
            id:         ma_visit&.id,
            first_name: ac_visit[:employee] ? ac_visit[:employee]["full_name"] : "No Field Provider"
          },
          start_time:           ac_visit[:start_at],
          end_time:             ac_visit[:end_at],
          service_code_name:    ac_visit[:service_code_name],
          canceled:             ac_visit[:cancelled],
          cancel_reason:        ac_visit[:cancelled] ? ac_visit[:cancel_code]["code"] : "",
          services:             ma_visit ? ma_visit.services.map {|s| s.to_builder.attributes! } : [],
          service_instructions: ma_visit&.service_instructions || ac_visit[:service_instructions],
          local:                ma_visit.present?,
          local_visit_id:       ma_visit&.id,
          visit_type_id:        ma_visit&.visit_type_id,
          program:              ma_visit&.program&.to_builder&.attributes!,
          display_status:       ma_visit&.display_status,
          cx_start:             round_time_15(Time.zone.parse(ac_visit[:start_at])),
          cx_end:               round_time_15(Time.zone.parse(ac_visit[:end_at])),
          notes:                ac_visit[:notes]&.sort do |x, y|
                                  Time.zone.parse(y[:created_at]) <=> Time.zone.parse(x[:created_at])
                                end

        }
        return OpenStruct.new({success?: true, payload: visit})
      end

      OpenStruct.new({success?: false, error: ac_visit_response.body})
    end

    def remote_visit_notes
      return [] unless @include_notes

      alayacare_path = "scheduler/visits/by_id/#{@internal_visit_id}"
      ac_visit_response = @api.get(alayacare_path)

      if ac_visit_response.success?
        ac_visit = begin
          JSON.parse(ac_visit_response.body)
        rescue StandardError
          nil
        end
        begin
          ac_visit["notes"]&.sort {|x, y| Time.zone.parse(y["created_at"]) <=> Time.zone.parse(x["created_at"]) }
        rescue StandardError
          # fail silently and do nothing
          []
        end
      end
    end
  end
end
