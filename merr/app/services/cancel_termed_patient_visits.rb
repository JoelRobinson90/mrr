# frozen_string_literal: true

class CancelTermedPatientVisits < ApplicationService
  def initialize(patient)
    @patient = patient
  end

  def call
    future_visits = get_future_visits
    if future_visits.any?
      cancel_code_id = EnvHelper.env_or_error("NOT_ELIGIBLE_CANCEL_CODE_ID")
      future_visits.each do |visit|
        visit.mark_canceled(cancel_code_id)
        visit.save!
      end
    end
  end

  private

  def get_future_visits
    @patient.visits.where(canceled: false).where("start_time > ?", Time.now)
  end
end
