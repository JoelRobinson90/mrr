# frozen_string_literal: true

module Mutations
  class CreateVisitGroup < BaseMutation
    field :id, ID, null: true
    field :errors, [String], null: false

    argument :visit_id,
             Integer,
             required: false
    argument :patient_id,
             Integer,
             required: false

    def resolve(create_visit_group_params)
      create_visit_group_params = create_visit_group_params.to_h
      @visit = Visit.find(create_visit_group_params[:visit_id])

      unless @visit[:visit_group_id]
        visit_group = VisitGroup.new
        visit_group.save
        @visit[:visit_group_id] = visit_group[:id]
      end

      @plus_one_visit = @visit.dup
      @plus_one_visit[:patient_id] = create_visit_group_params[:patient_id]
      @plus_one_visit.services = @visit.services

      # fields that need to be reset for the new visit to be created
      reset_new_visit_fields!

      # create resources on new visit
      add_new_resources!


      if @visit.save && @plus_one_visit.save
        {
          id:     @visit[:visit_group_id],
          errors: []
        }
      else
        {
          visit_group: nil,
          errors:      @plus_one_visit.errors.full_messages
        }
      end
    end

    def add_new_resources!
     @visit.visit_resources.each do |resource|
        provider = FieldProvider.find_by(id: @visit[:field_provider_id])
        @plus_one_visit.visit_resources.build({
          field_provider: provider,
          start_time: resource[:start_time],
          end_time: resource[:end_time],
          in_home: resource[:in_home]
        })
      end
    end

    def reset_new_visit_fields!
      @plus_one_visit.ma_id = nil
      @plus_one_visit.external_id = nil
      @plus_one_visit.canceled = false
      @plus_one_visit.cancel_code = nil
      @plus_one_visit.alayacare_status = nil
      @plus_one_visit.status = "scheduled"
    end
  end
end
