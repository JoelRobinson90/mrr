# frozen_string_literal: true

module Queries
  module AlayacareVisitQueries
    def get_alayacare_visits(date:, demand_partner_id: nil)
      demand_partner_id ||= current_user.account.try(:demand_partner_id)
      date = Date.parse(date)

      results = Routing::GetAppointments.call(date, date)
      raise Error, results.error unless results.success?

      visits = results.payload
      visits.filter! {|visit| authorized?(:read, visit) }
      visits
    end

    class Error < StandardError; end
  end
end
