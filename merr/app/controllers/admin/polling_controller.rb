# typed: true
# frozen_string_literal: true

module Admin
  class PollingController < BaseController
    def patients_worklist
      prospects_count        = PatientProspect.count
      needs_scheduling_count = Patient.where(status: PatientConstants::NEEDS_SCHEDULING_STATUS).count

      render_partial_component "AdminNavigation", {
        prospects_count:        prospects_count,
        needs_scheduling_count: needs_scheduling_count,
        user_role:              current_user.account_type
      }
    end
  end
end
