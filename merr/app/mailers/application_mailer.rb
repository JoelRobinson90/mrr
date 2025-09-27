# frozen_string_literal: true

# typed: true
require "postmark-rails/templated_mailer"

class ApplicationMailer < ActionMailer::Base
  include PostmarkRails::TemplatedMailerMixin

  default from: "MedArrive <noreply@medarrive.com>"
  layout "mailer"
end
