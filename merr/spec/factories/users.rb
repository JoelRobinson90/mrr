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
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    has_random_password { false }
    association :account, factory: :field_provider # Setting this account type as the default
    association :address, factory: :address

    factory :field_admin_user do
      association :account, factory: :field_admin
    end

    factory :field_provider_user do
      association :account, factory: :field_provider
    end

    factory :medarrive_admin_user do
      association :account, factory: :medarrive_admin
    end

    factory :medarrive_customer_support_user do
      association :account, factory: :medarrive_customer_support
    end

    factory :super_admin_user do
      sequence(:email) {|n| User::SUPER_ADMIN_EMAILS[n % User::SUPER_ADMIN_EMAILS.length] }
      association :account, factory: :medarrive_admin
    end

    factory :external_account_user do
      association :account, factory: :external_account
    end

    factory :demand_coordinator_user do
      transient do
        demand_partner { nil }
      end

      association :account, factory: :demand_coordinator

      after :build do |user, options|
        user.account.demand_partner = options.demand_partner if options.demand_partner
      end
    end

    trait :invited do
      has_random_password { true }

      after :create, &:create_reset_password_token!
    end

    trait :with_address do
      after :create do |record|
        record.address = FactoryBot.create(:address, addressable: record)
      end
    end
  end
end
