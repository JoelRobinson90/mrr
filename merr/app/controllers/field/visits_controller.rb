# typed: true
# frozen_string_literal: true

module Field
  class VisitsController < BaseController
    load_and_authorize_resource
    include Visits

    def update
      update_as("field_user")
    end

    def index
      index_visits("FieldScheduleVisitPage")
    end

    private

    def visit_params
      params.require(:visit).permit(:start_time, :end_time, :service_instructions, :external_id, :patient_id,
                                    :program_id, :visit_type_id, :no_services, service_ids: [])
    end
  end
end
