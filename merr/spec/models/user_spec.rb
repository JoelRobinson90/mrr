# frozen_string_literal: true

# typed: true
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
require "rails_helper"

RSpec.describe User, type: :model do
  # test password complexity

  let(:user) { build(:user) }

  describe "active user" do
    it "can be deactivated" do
      expect(user.active_for_authentication?).to be true
      user.update(deactivated: true)
      expect(user.active_for_authentication?).to be false
    end
  end

  describe "#is_super_admin?" do
    before { stub_const("User::SUPER_ADMIN_EMAILS", ["super_admin@medarrive.com"]) }

    it "only returns true for users with one of our hardcoded super admin emails" do
      expect(build(:user).is_super_admin?).to be false
      expect(build(:user, email: "super_admin@medarrive.com").is_super_admin?).to be true
    end
  end

  describe "#is_medarrive_account?" do
    it "returns whether a user belongs to us or not" do
      expect(build(:medarrive_admin_user).is_medarrive_account?).to be true
      expect(build(:medarrive_customer_support_user).is_medarrive_account?).to be true
      expect(build(:field_admin_user).is_medarrive_account?).to be false
      expect(build(:field_provider_user).is_medarrive_account?).to be false
    end
  end

  describe "#is_field_account?" do
    it "returns whether a user belongs to a field org or not" do
      expect(build(:field_admin_user).is_field_account?).to be true
      expect(build(:field_provider_user).is_field_account?).to be true
      expect(build(:medarrive_admin_user).is_field_account?).to be false
      expect(build(:medarrive_customer_support_user).is_field_account?).to be false
    end
  end

  describe "#is_patient?" do
    it "returns if user is a patient" do
      expect(build(:field_admin_user).is_patient?).to be false
      expect(build(:field_provider_user).is_patient?).to be  false
      expect(build(:medarrive_admin_user).is_patient?).to be false
      expect(build(:medarrive_customer_support_user).is_patient?).to be false
      expect(build(:patient, :with_user).user.is_patient?).to be true
    end
  end

  describe "#from_auth_user" do
    let!(:test_email) { "authuser@medarrive.com" }
    let(:auth_user) do
      AuthUser.new(
        provider:            "oktaoauth",
        email:               test_email,
        uid:                 "UID",
        first_name:          "Auth",
        last_name:           "User",
        phone_number:        "7345467319",
        account_type:        "MedarriveOperationsAdmin",
        field_org_name:      "N/A",
        demand_partner_name: "N/A"
      )
    end

    it "creates new user" do
      User.find_by(email: test_email)&.delete

      user = User.from_auth_user(auth_user)

      expect(user.persisted?).to be true
      expect(user.account.class.name).to eq("MedarriveAdmin")
      expect(user.email).to eq(test_email)
      expect(user.account.first_name).to eq("Auth")
    end

    it "finds existing user" do
      User.find_or_create_by(email: test_email)

      user = User.from_auth_user(auth_user)

      expect(user.email).to eq(test_email)
    end

    it "fails with incorrect type" do
      auth_user.account_type = "NotFound"

      user = User.from_auth_user(auth_user)

      expect(user.persisted?).to be false
      expect(user.errors.full_messages.to_sentence).to eq("Account type 'NotFound' not found.")
    end

    it "cascades verification errors from account" do
      User.find_by(email: test_email)&.delete

      auth_user.account_type = "FieldProvider"

      user = User.from_auth_user(auth_user)

      expect(user.valid?).to be false
      expect(user.errors.full_messages.to_sentence).to eq("Account field org must exist")
    end
  end
end
