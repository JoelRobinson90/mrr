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

  context "tags" do
    let(:tag) { create :tag }

    context "accessed by super admin" do
      let(:user) { create(:super_admin_user) }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, tag) }
      end
    end

    context "accessed by a medarrive_admin" do
      let(:account) { build :medarrive_admin }

      it { is_expected.to be_able_to(:read, tag) }
      it { is_expected.to be_able_to(:update, tag) }
    end

    context "accessed by a medarrive_customer_support" do
      let(:account) { build :medarrive_customer_support }

      it { is_expected.to be_able_to(:read, tag) }
      it { is_expected.to be_able_to(:create, tag) }
      it { is_expected.to_not be_able_to(:update, tag) }
    end

    context "accessed by a medarrive_clinical_operation" do
      let(:account) { build :medarrive_clinical_operation }

      it { is_expected.to be_able_to(:read, tag) }
      it { is_expected.to be_able_to(:create, tag) }
      it { is_expected.to_not be_able_to(:update, tag) }
    end

    context "accessed by field admins" do
      let(:account) { build :field_admin, field_org: field_org }

      it { is_expected.to be_able_to(:read, tag) }
      it { is_expected.to be_able_to(:update, tag) }
    end

    context "accessed by field dispatchers" do
      let(:account) { build :field_dispatcher, field_org: field_org }

      it { is_expected.not_to be_able_to(:read, tag) }
      it { is_expected.not_to be_able_to(:update, tag) }
    end

    context "accessed by field providers" do
      let(:account) { build :field_provider, field_org: field_org }

      it { is_expected.not_to be_able_to(:read, tag) }
      it { is_expected.not_to be_able_to(:update, tag) }
    end
  end
end
