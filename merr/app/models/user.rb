# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                              :bigint           not null, primary key
#  account_type                    :string           indexed => [account_id]
#  authentication_token            :text             indexed
#  authentication_token_created_at :datetime
#  current_sign_in_at              :datetime
#  current_sign_in_ip              :inet
#  deactivated                     :boolean          default(FALSE), not null
#  email                           :string           default(""), not null, indexed
#  encrypted_password              :string           default(""), not null
#  failed_attempts                 :integer          default(0), not null
#  has_random_password             :boolean          default(FALSE)
#  last_sign_in_at                 :datetime
#  last_sign_in_ip                 :inet
#  locked_at                       :datetime
#  provider                        :string           indexed
#  remember_created_at             :datetime
#  reset_password_sent_at          :datetime
#  reset_password_token            :string           indexed
#  sign_in_count                   :integer          default(0), not null
#  uid                             :string           indexed
#  unlock_token                    :string           indexed
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  account_id                      :bigint           indexed => [account_type]
#
# Indexes
#
#  index_users_on_account_type_and_account_id  (account_type,account_id)
#  index_users_on_authentication_token         (authentication_token) UNIQUE
#  index_users_on_email                        (email) UNIQUE
#  index_users_on_provider                     (provider)
#  index_users_on_reset_password_token         (reset_password_token) UNIQUE
#  index_users_on_uid                          (uid)
#  index_users_on_unlock_token                 (unlock_token) UNIQUE
#
class User < ApplicationRecord
  include OptionalPhysicalAddress
  include PushToExternal

  SUPER_ADMIN_EMAILS = %w[
    erik@medarrive.com
    jonathan@medarrive.com
    leslie@medarrive.com
    chris@medarrive.com
    soren@medarrive.com
    elena@medarrive.com
    tharika@medarrive.com
    pete@medarrive.com
    marlonm@medarrive.com
    sunayana@medarrive.com
    tim.kellogg@medarrive.com
    liliana.liu@medarrive.com
    blair@medarrive.com
    vidya@medarrive.com
    ravi@medarrive.com
  ].freeze

  attr_reader :password_suggestions

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :lockable, :token_authenticatable,
         :timeoutable, :omniauthable, omniauth_providers: [:oktaoauth]

  belongs_to :account, polymorphic: true, inverse_of: :user

  has_many :admin_notes, inverse_of: :creator, foreign_key: :creator_id

  accepts_nested_attributes_for :account

  validates :email, presence: {if: -> { account_type == "FieldProvider" }}

  def password_required?
    false
  end

  def assign_random_password
    password = SecureRandom.hex(32)
    assign_attributes(
      password:              password,
      password_confirmation: password,
      has_random_password:   true
    )
  end

  def self.from_auth_user(auth_user)
    user = User.find_or_create_by(email: auth_user.email) do |user|
      user.provider = auth_user.provider
      user.uid = auth_user.uid

      accountStr = auth_user.account_type

      # translation layer between Okta and MedArrive
      accountStr = accountStr.gsub("MedarriveOperationsAdmin", "MedarriveAdmin")
      accountStr = accountStr.gsub("MedarriveCareCoordinator", "MedarriveClinicalOperation")

      accountKlass = accountStr&.safe_constantize

      if accountKlass.blank?
        user.errors.add(:account, "type '#{accountStr}' not found.")
        return user
      end

      user.account = accountKlass.from_auth_user(auth_user)
    end
  end

  # Effectively disable timeouts for users unless overridden
  DEFAULT_TIMEOUT_IN = 1.year
  def timeout_in
    account.session_timeout_in || DEFAULT_TIMEOUT_IN
  end

  # This tells Devise not to allow a deactivated account to log in
  def active_for_authentication?
    super && !deactivated
  end

  # This is the message Devise will use when a deactivated account is used.
  def inactive_message
    "Your account has been deactivated"
  end

  def display_role
    is_super_admin? ? "Super Admin" : account_type.titleize
  end

  # Account types
  # TODO: Replace this with a dynamic method generator for all account types

  def is_field_account?
    account_type.starts_with? "Field"
  end

  def is_field_admin?
    account_type == "FieldAdmin"
  end

  def is_field_dispatcher?
    account_type == "FieldDispatcher"
  end

  def is_field_provider?
    account_type == "FieldProvider"
  end

  def is_medarrive_account?
    account_type.starts_with? "Medarrive"
  end

  def is_medarrive_admin?
    account_type == "MedarriveAdmin"
  end

  def is_medarrive_customer_support?
    account_type == "MedarriveCustomerSupport"
  end

  def is_medarrive_clinical_operations?
    account_type == "MedarriveClinicalOperation"
  end

  def is_demand_coordinator?
    account_type == "DemandCoordinator"
  end

  def is_patient?
    account_type == "Patient"
  end

  def is_admin?
    account_type == "MedarriveAdmin" || is_super_admin?
  end

  def is_external_account?
    account_type == "ExternalAccount"
  end

  def is_field_scheduler?
    field_scheduler_types = %w[FieldProvider ExternalAccount]
    field_scheduler_types.include?(account_type)
  end

  # Replace is_ prefixed methods with rails preferred
  alias medarrive_admin? is_admin?

  def is_super_admin?
    SUPER_ADMIN_EMAILS.include?(email) || (email == "super_admin@medarrive.com" && Rails.env.development?)
  end

  def create_reset_password_token!
    set_reset_password_token
  end

  def full_name
    account&.display_name
  end

  def organization
    return account.field_org if is_field_provider?
    return account.demand_partner if is_demand_coordinator? || is_patient?

    account.organization_name #  default for other account types
  end

  # sync to external when email is changed.
  def push_to_alayacare(mode)
    if mode == :update && account_type == "FieldProvider" && !account.changed?
      # if the account is dirty, then it will be saved right after this and can trigger it's own sync.
      return Alayacare::FieldProviderCreateOrUpdateService.call(mode, account)
    end

    OpenStruct.new(success?: true)
  end

  def to_builder(include_external_id: false)
    Jbuilder.new do |user|
      user.call(self, :id, :email, :account_type, :created_at, :display_role, :organization)
      user.display_name account.display_name
      user.account account
      user.external_id account.external_id if include_external_id
    end
  end
end
