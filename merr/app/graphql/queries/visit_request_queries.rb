# frozen_string_literal: true

module Queries
  module VisitRequestQueries
    def get_visit_requests(lookahead:, pending: false)
      visit_requests = VisitRequest.accessible_by(current_ability).order(created_at: :desc)
      visit_requests = visit_requests.pending if pending

      visit_requests = visit_requests.with_statuses if lookahead.selects?(:status)
      visit_requests = visit_requests.includes(:patient) if lookahead.selects?(:patient)
      visit_requests = visit_requests.includes(:program) if lookahead.selects?(:program)
      visit_requests = visit_requests.includes(:creator) if lookahead.selects?(:creator)
      visit_requests = visit_requests.includes(:services) if lookahead.selects?(:services)

      visit_requests
    end
  end
end
