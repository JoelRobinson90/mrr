# typed: true
# frozen_string_literal: true

class FieldUserCreator
  # Creates a field user under a field org and sends them an invite email

  class FieldUserCreatorError < StandardError; end

  attr_reader :email, :field_org, :role_klass, :account_attrs, :preview, :user

  def initialize(email, field_org, role_klass, account_attrs = {}, preview: false)
    @email = email
    @field_org = field_org
    @role_klass = role_klass
    @account_attrs = account_attrs
    @preview = preview
  end

  def execute
    @user = find_or_initialize_user
    return user if preview

    save_user if user.new_record?
    send_invite_email if user.has_random_password?
    user
  end

  private

  def find_or_initialize_user
    User.find_or_initialize_by(email: email) do |user|
      user.assign_random_password
      user.account = build_account
    end
  end

  def build_account
    role_klass.new(account_attrs.merge(field_org: field_org))
  end

  def save_user
    raise FieldUserCreatorError, user.errors.full_messages.join(". ") unless user.valid?

    raise FieldUserCreatorError, user.errors.full_messages.join(". ") unless user.account.valid?

    user.save!
  end

  def send_invite_email
    # TODO: use deliver_later once we have background jobs running in production MED-371
    UserMailer.field_user_invite(user).deliver_now
  end
end
