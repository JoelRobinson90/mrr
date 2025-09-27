# frozen_string_literal: true

# typed: true
require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  let(:user) { account.user }
  let(:account) { nil }

  let(:field_org) { create :field_org }
  let(:other_field_org) { create :field_org }

  subject(:ability) { Ability.new(user) }
  # Model-centric approach

  context "users and accounts" do
    let(:medarrive_user_account) { create :medarrive_admin }

    context "admin accounts" do
      context "accessed by super admin" do
        let(:user) { create(:super_admin_user) }

        %i[create update read].each do |function|
          it { is_expected.to be_able_to(function, medarrive_user_account) }
          it { is_expected.to be_able_to(function, medarrive_user_account.user) }
        end
      end

      context "accessed by a medarrive_admin" do
        let(:account) { build :medarrive_admin }

        %i[create update read].each do |function|
          it { is_expected.to be_able_to(function, medarrive_user_account) }
          it { is_expected.to be_able_to(function, medarrive_user_account.user) }
        end
      end

      context "accessed by medarrive customer support" do
        let(:account) { build :medarrive_customer_support }

        it { is_expected.to_not be_able_to(:read, medarrive_user_account) }
        it { is_expected.to_not be_able_to(:read, medarrive_user_account.user) }
      end

      context "accessed by medarrive clinical operations" do
        let(:account) { build :medarrive_clinical_operation }

        it { is_expected.to_not be_able_to(:read, medarrive_user_account) }
        it { is_expected.to_not be_able_to(:read, medarrive_user_account.user) }
      end

      context "accessed by other users" do
        let(:account) { build :field_admin }

        it { is_expected.to_not be_able_to(:read, medarrive_user_account) }
        it { is_expected.to_not be_able_to(:read, medarrive_user_account.user) }
      end
    end

    context "field accounts" do
      let(:field_admin) { build :field_admin, field_org: field_org }
      let(:field_dispatcher) { build :field_dispatcher, field_org: field_org }
      let(:field_provider) { build :field_provider, field_org: field_org }

      let(:field_admin_outside_org) { build :field_admin, field_org: other_field_org }
      let(:field_dispatcher_outside_org) { build :field_dispatcher, field_org: other_field_org }
      let(:field_provider_outside_org) { build :field_provider, field_org: other_field_org }

      context "accessed by super admin" do
        let(:user) { create(:super_admin_user) }

        %i[create update read].each do |function|
          it { is_expected.to be_able_to(function, field_admin) }
          it { is_expected.to be_able_to(function, field_dispatcher) }
          it { is_expected.to be_able_to(function, field_provider) }
        end
      end

      context "accessed by a medarrive_admin" do
        let(:account) { build :medarrive_admin }

        it { is_expected.to be_able_to(:read, field_admin) }
        it { is_expected.to be_able_to(:read, field_dispatcher) }
        it { is_expected.to be_able_to(:read, field_provider) }
      end

      context "accessed by field admin" do
        let(:account) { build :field_admin, field_org: field_org }

        %i[create update read].each do |function|
          it { is_expected.to be_able_to(function, field_admin) }
          it { is_expected.to be_able_to(function, field_dispatcher) }
          it { is_expected.to be_able_to(function, field_provider) }
        end

        it { is_expected.not_to be_able_to(:read, field_admin_outside_org) }
        it { is_expected.not_to be_able_to(:read, field_dispatcher_outside_org) }
        it { is_expected.not_to be_able_to(:read, field_provider_outside_org) }
      end

      context "accessed by field dispatchers" do
        let(:account) { build :field_dispatcher, field_org: field_org }

        it { is_expected.to be_able_to(:read, field_admin) }
        it { is_expected.not_to be_able_to(:update, field_admin) }
        it { is_expected.to be_able_to(:read, field_dispatcher) }
        it { is_expected.to be_able_to(:update, field_dispatcher) }
        it { is_expected.to be_able_to(:update, field_provider) }

        it { is_expected.not_to be_able_to(:read, field_admin_outside_org) }
        it { is_expected.not_to be_able_to(:read, field_dispatcher_outside_org) }
        it { is_expected.not_to be_able_to(:read, field_provider_outside_org) }
      end
    end
  end
end
