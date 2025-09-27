# frozen_string_literal: true

module Queries
  module VisitQueries
    include Routing::Helpers

    # DEPRECATED: old implementation for fetching visit
    def __get_visit(alayacare_visit_id: nil, visit_id: nil)
      visit = nil
      @api = Authentication::Api.new(Authentication::AlayacareBroker)

      alayacare_path = if alayacare_visit_id
                         "scheduler/visits/#{alayacare_visit_id}"
                       elsif visit_id
                         "scheduler/visits/by_id/#{visit_id}"
                       end

      return nil if visit_id.blank? && alayacare_visit_id.blank?

      ac_visit_response = @api.get(alayacare_path)

      if ac_visit_response.success?
        ac_visit = begin
          JSON.parse(ac_visit_response.body)
        rescue StandardError
          nil
        end

        visit = instantiate_visit(visit: ac_visit)
      end

      visit
    end

    # 4 KINDS OF IDS!!!!
    # TODO: [v1] Remove AC and external
    def get_visit(lookahead:, alayacare_visit_id: nil, id: nil, ma_id: nil, external_id: nil)
      ma_visit = if id
                   Visit.find_by(id: id)
                 elsif ma_id
                   Visit.find_by(ma_id: ma_id)
                 elsif external_id
                   Visit.find_by(external_id: external_id)
                 end
      # if program.v2 flag is enabled then just return local visit and skip fetching from AC
      return ma_visit if ma_visit&.program&.v2

      visit = nil
      response = Alayacare::FetchVisit.call(
        alayacare_visit_id,
        internal_visit_id: external_id,
        include_notes:     lookahead.selects?(:notes)
      )
      response.success? ? response.payload : nil
    end

    def get_visits(start_time: nil, end_time: nil, limit: 5)
      visits = Visit.where(field_provider: current_user.account)
      visits = visits.where(start_time: [start_time..end_time]) if start_time && end_time
      visits.order(start_time: :asc).limit(limit)
    end
  end
end
