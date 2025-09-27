# frozen_string_literal: true

# typed: true
class PatientMailer < ApplicationMailer
  # This is defined in the status_update Postmark template.
  def status_update(patient, status)
    self.template_model = {
      patient: {
        first_name: patient.first_name
      },
      status:  status
    }

    mail(to: patient.email)
  end
end
