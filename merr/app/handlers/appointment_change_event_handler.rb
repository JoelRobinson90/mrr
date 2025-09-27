# typed: true
# frozen_string_literal: true

class AppointmentChangeEventHandler

  def call(event)
    Rails.logger.debug(["*** #{self.class.name}", event, event.data, event.metadata])

    changes = event.data.dig(:meta, :dirty_fields).map(&:to_sym)

    appointment = Appointment.find(event.data.fetch(:object_id))
    appointment_changes = event.data.fetch(:meta)

    # Check to see if we need to execute actions for status changes
    # assume this is a desired change and exit the change event handler
    status_changes_to_handler(appointment, appointment_changes) if appointment_changes.dig(:status, :to)
    status_changes_from_handler(appointment, appointment_changes) if appointment_changes.dig(:status, :was)
  rescue StandardError => e
    # Add additional information about the scope of exception due
    # to events being more difficult to trace then sync processes
    Sentry.with_scope do |scope|
      scope.set_tags(event_processor: self.class.name.to_s, event: event.data.to_s)

      Sentry.capture_exception(e)
      Rails.logger.error(e)
    end
  end

  def status_changes_to_handler(appointment, appointment_changes)
    case appointment_changes.dig(:status, :to)
    when "Alayacare"
      send_alayacare_or_report_issues(appointment)
    end
  rescue StandardError => e
    Sentry.with_scope do |_scope|
      Sentry.capture_exception(e)
      Rails.logger.error(e)
      annotate_system_change(appointment,
                             "An error has occured attempting to send clinical summary pdf to Alayacare. Please contact the support team.")
    end
  end

  def send_alayacare_or_report_issues(appointment)
    if appointment.order
      annotate_system_change(appointment, "Sending clinical summary pdf to Alayacare due to status change")
      Alayacare::ClientPdfUploadService.call(appointment.order, generated_pdf)
      annotate_system_change(appointment,
                             ["MedArrieve has sent a clinical summary pdf to Alayacare.",
                              "This has been triggered by the appointment status change"].join(" "))

    else
      annotate_system_change(appointment, "Unable to send clinical summary pdf to Alayacare due to missing order.")
    end
  end

  def status_changes_from_handler(appointment, appointment_changes)
    patient_triggering_statuses = [
      "Alayacare",
      "Assigned",
      "Awaiting Scheduling",
      "In Progress",
      "Pending Acceptance",
      "Vacant"
    ]

    new_status = appointment_changes.dig(:status, :to)

    return unless new_status.in?(patient_triggering_statuses)

    annotate_system_change(appointment.patient, "Altering patient status due to appointment moving to #{new_status}")
    appointment.patient.update(status: "Referred: Scheduled")
  end

  def override_date(time, target, tz)
    return nil if time.blank?

    safe_target = target.in_time_zone(tz)
    safe_time = time.in_time_zone(tz)

    safe_time = safe_time.change(year: safe_target.year, month: safe_target.month, day: safe_target.day)

    safe_time.in_time_zone("UTC")
  end

  def annotate_system_change(noted, comment)
    full_comment = "Appointment Event Change Handler: #{comment}"

    Rails.logger.debug(full_comment)
    AdminNote.create(
      content: full_comment,
      notable: noted
    )
  end
end
