# typed: true
# frozen_string_literal: true

class Send24HoursPriorToAppointmentJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    # For Covid Vaccine logic, the appointment should be in assigned
    return unless appointment.status == "Assigned"

    # If the appointment is in the past, mark job completed
    return unless appointment.start_time > Time.current

    # if the appointment is in the future,
    # and it is no more than 30 hours in the future
    if appointment.start_time < 30.hours.from_now
      Sms::SmsSender.call(
        "reminder",
        appointment.demand_partner,
        appointment
      )
    else
      Send24HoursPriorToAppointmentJob.set(wait_until: appointment.start_time - 24.hours).perform_later(appointment)
    end
  end
end
