# frozen_string_literal: true

module Routing
  class RescheduleCancelledVisit < ::ApplicationService
    def initialize(visit:, start_time:, end_time:, field_provider:, resources:)
      @visit = visit
      @start_time = start_time
      @end_time = end_time
      @field_provider = field_provider
      @resources = resources || []
    end

    def call
      # if visit is not cancelled don't do anything
      if !@visit.canceled && @visit.cancel_code_id.blank?
        return OpenStruct.new success?: false, error: "visit must be cancelled"
      end

      @new_visit = @visit.dup

      @new_visit.original_visit = @visit if @new_visit.original_visit.blank?

      @new_visit.start_time = @start_time
      @new_visit.end_time = @end_time
      @new_visit.field_provider = @field_provider

      # if visit is being rescheduled, the only internal status applicable is 'scheduled'
      @new_visit.status = "scheduled"
      @new_visit.canceled = false
      @new_visit.confirmed = false
      @new_visit.cancel_code_id = nil
      race_condition_check = if @visit.program&.v2?
        Routing::CheckRaceCondition.call(@new_visit)
      else
        Alayacare::CheckRaceCondition.call(@new_visit)
      end
      
      return OpenStruct.new success?: false, error: race_condition_check.error unless race_condition_check.success?

      # fields that need to be reset for the new visit to be created
      reset_new_visit_fields!

      # move services since associations are not copied when calling .dup
      copy_associations!

      # visit linkages
      update_linkages!

      # increment reschedule count
      update_reschedule_count!

      # create resources on new visit
      add_new_resources!

      # saving original visit will trigger saving new visit since it's an association.
      if @visit.save
        OpenStruct.new success?: true, payload: @new_visit
      else
        OpenStruct.new success?: false, error: @visit.errors.full_messages.join(",")
      end
    end

    private

    def add_new_resources!
      @resources.each do |resource|
        provider = FieldProvider.find_by(external_id: resource[:resource_id])
        @new_visit.visit_resources.build({
          field_provider: provider,
          start_time: resource[:start_time],
          end_time: resource[:end_time],
          in_home: resource[:in_home]
        })
      end
    end

    def reset_new_visit_fields!
      @new_visit.ma_id = nil
      @new_visit.external_id = nil
      @new_visit.canceled = false
      @new_visit.cancel_code = nil
      @new_visit.alayacare_status = nil
      @new_visit.status = "scheduled"
    end

    def copy_associations!
      @new_visit.services = @visit.services
      # should we also move admin_notes ?
      # should we also move scheduler_log ? 
    end

    def update_linkages!
      @new_visit.previous_linked_visit = @visit
      @visit.next_linked_visit = @new_visit
    end

    def update_reschedule_count!
      @new_visit.reschedule_count = (@visit.reschedule_count || 0) + 1
    end
  end
end
