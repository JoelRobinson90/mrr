# frozen_string_literal: true

module Routing
  class GetVisitsForOptimizer < ::ApplicationService
    include Helpers
    def initialize(start_date, end_date, fp_filter_list: nil)
      @start_date = start_date
      @end_date = end_date.end_of_day
      @fp_filter_list = fp_filter_list
    end

    def call
      query = VisitResource.includes({visit: {patient: :address}}, :field_provider)
                           .where("visit_resources.start_time >= ?", @start_date)
                           .where("visit_resources.start_time <= ?", @end_date)
                           .where(visit: {canceled: false})

      query = query.where(field_provider: {external_id: @fp_filter_list}) if @fp_filter_list.present?

      @visit_resources = query.all.map {|visit_resource| format_visit_resource(visit_resource) }

      OpenStruct.new(success?: true, message: "Visits fetched.", payload: @visit_resources)
    end

    def format_visit_resource(visit_resource)
      OpenStruct.new(
        visit_id:           visit_resource.visit.external_id,
        start_time:         visit_resource.start_time,
        end_time:           visit_resource.end_time,
        fp_id:              visit_resource.field_provider&.external_id,
        location:           visit_resource.visit.lat_long,
        program_id:         visit_resource.visit.program_id
      )
    end
  end
end
