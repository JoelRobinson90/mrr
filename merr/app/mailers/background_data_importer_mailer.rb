# typed: true
# frozen_string_literal: true

class BackgroundDataImporterMailer < Devise::Mailer
  helper :application

  default from: "MedArrive <noreply@medarrive.com>"

  include Rails.application.routes.url_helpers
  include Devise::Controllers::UrlHelpers

  default template_path: "data_import/mailer"

  def import_result(upload_object, result)
    @upload = upload_object
    @result = result
    @result.errors ||= "None."
    @result.messages ||= "See errors."

    mail to: upload_object.user.email, subject: "MedArrive Patient Import Results"
  end
end
