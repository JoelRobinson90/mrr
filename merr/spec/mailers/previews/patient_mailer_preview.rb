# frozen_string_literal: true

# typed: true
# Preview all emails at http://localhost:3000/rails/mailers/patient_mailer
class PatientMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/patient_mailer/status_update
  def status_update
    PatientMailer.status_update(Patient.first, "In Treatment").prerender
  end
end
