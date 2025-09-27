# typed: true
# frozen_string_literal: true

module UserAccount
  extend ActiveSupport::Concern

  included do
    has_one :user, as: :account, inverse_of: :account
    accepts_nested_attributes_for :user

    delegate :email, to: :user, allow_nil: true
    delegate :authentication_token, to: :user, allow_nil: true

    def self.from_auth_user(auth_user)
      create do |account|
        account.first_name = auth_user.first_name
        account.last_name = auth_user.last_name

        phone_number = auth_user.phone_number.presence

        type = name

        account.phone = phone_number if type == "FieldProvider"

        account.field_org = FieldOrg.find_by(name: auth_user.field_org_name) if type.start_with?("Field")

        account.phone_number = phone_number if type.start_with?("Medarrive")

        if type == "DemandCoordinator"
          account.demand_partner = DemandPartner.find_by(name: auth_user.demand_partner_name)
        end
      end
    end
  end

  def type
    self.class.name.underscore
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def display_name
    full_name.presence || user.email
  end

  def session_timeout_in
    nil
  end

  # Account types

  def is_field_admin?
    type == "field_admin"
  end

  def is_field_dispatcher?
    type == "field_dispatcher"
  end

  def is_field_provider?
    type == "field_provider"
  end

  def is_medarrive_admin?
    type == "medarrive_admin"
  end

  def is_field_account?
    type.starts_with? "field_"
  end

  def is_demand_coordinator?
    type == "demand_coordinator"
  end
end
