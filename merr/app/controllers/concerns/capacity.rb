# frozen_string_literal: true

module Capacity
  extend ActiveSupport::Concern

  def get_availability_by_date
    error_message = nil

    @start_date = params[:start_date].to_date || Date.today
    @end_date = params[:end_date].to_date.end_of_day if params[:end_date]
    @patient = Patient.find params[:patient_id] if params[:patient_id]

    @shifts = profile("get shifts") do
      Routing::GetShifts.call(@start_date, @end_date, include_users: true).payload if params[:include_shifts]
    end

    profile("get local visits") do
      @visits = Routing::GetVisits.call(@start_date, @end_date,
                                        false, patient: @patient).payload
    end

    if current_user.is_external_account?
      @visits = @visits.select { |visit| current_user.account.program_ids.include?(visit.program["id"]) }
    end

    @visits = profile("calculate retroactive drive time") { Routing::AddRetroactiveDriveTime.call(@visits).payload }

    render json: {
      shifts:        @shifts,
      visits:        @visits,
      error_message: error_message
    }
  end
end
