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

  context "patients" do
    let(:patient) { create :patient }
    let(:appointment) { create :appointment }

    context "accessed by super admin" do
      let(:user) { create(:super_admin_user) }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient) }
      end
    end

    context "accessed by medarrive admin" do
      let(:account) { create :medarrive_admin }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient) }
      end
    end

    context "accessed by medarrive customer support" do
      let(:account) { create :medarrive_customer_support }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient) }
      end
    end

    context "accessed by medarrive clinical operations" do
      let(:account) { create :medarrive_clinical_operation }
      let(:program) { create :program }
      let(:patient_program) { PatientProgram.create(program_id: program.id, patient_id: patient.id) }
      let(:ext_acct_program) { ExtAcctProgram.create(program_id: program.id, external_account_id: account.id) }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient) }
      end
    end

    context "accessed by field providers" do
      let(:account) { create :field_provider }

      it { is_expected.to be_able_to(:read, patient) }
    end
  end
end
