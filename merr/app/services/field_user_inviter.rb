# typed: true
# frozen_string_literal: true

class FieldUserInviter
  # Takes an array of emails, along with a single field org and role,
  # and creates any users that don't already exist

  class FieldUserInviterError < StandardError; end

  attr_reader :emails, :field_org, :role_klass, :preview

  def initialize(emails, field_org, role_klass, preview: false)
    @emails = emails
    @field_org = field_org
    @role_klass = role_klass
    @preview = preview
  end

  def execute
    # Validate emails
    emails.each do |email|
      raise FieldUserInviterError, "#{email} is not a valid email address" unless email =~ URI::MailTo::EMAIL_REGEXP
    end

    # Check which emails don't exist yet
    existing_emails = User.where(email: emails).pluck(:email)
    new_emails = emails - existing_emails

    # Build user and account records
    new_emails.map {|email| FieldUserCreator.new(email, field_org, role_klass, preview: preview).execute }
  end
end
