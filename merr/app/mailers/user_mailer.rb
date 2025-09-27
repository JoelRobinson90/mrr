# typed: true
# frozen_string_literal: true

class UserMailer < Devise::Mailer
  helper :application

  default from: "MedArrive <noreply@medarrive.com>"

  include Rails.application.routes.url_helpers
  include Devise::Controllers::UrlHelpers

  default template_path: "users/mailer"

  # To trigger this email:
  # UserMailer.provider_invite(user).deliver_later (or deliver_now)
  def field_user_invite(user)
    @user = user
    @field_org = user.account.field_org
    @token = user.create_reset_password_token!
    mail to: user.email, subject: "Welcome to MedArrive"
  end

  def office_user_invite(user)
    @user = user
    @token = user.create_reset_password_token!
    mail to: user.email, subject: "Confirm your MedArrive Account"
  end
end
