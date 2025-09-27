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

  context "rails admin" do
    context "accessed by super admins" do
      let(:user) { build :super_admin_user }

      it { is_expected.to be_able_to(:access, :rails_admin) }
    end

    context "accessed by medarrive admins" do
      let(:account) { create :medarrive_admin }

      it { is_expected.not_to be_able_to(:access, :rails_admin) }
    end

    context "accessed by other users" do
      let(:account) { create :field_admin }

      it { is_expected.not_to be_able_to(:access, :rails_admin) }
    end
  end

  context "admin notes" do
    let(:admin_note) { create :admin_note }

    context "accessed by super admin" do
      let(:user) { create(:super_admin_user) }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, admin_note) }
      end
    end

    context "accessed by a medarrive_admin" do
      let(:account) { build :medarrive_admin }

      it { is_expected.to be_able_to(:read, admin_note) }
      it { is_expected.to_not be_able_to(:update, admin_note) }
    end

    context "accessed by a medarrive_customer_support" do
      let(:account) { build :medarrive_customer_support }

      it { is_expected.to be_able_to(:read, admin_note) }
      it { is_expected.to be_able_to(:create, admin_note) }
      it { is_expected.to_not be_able_to(:update, admin_note) }
    end

    context "accessed by a medarrive_clinical_operation" do
      let(:account) { build :medarrive_clinical_operation }

      it { is_expected.to be_able_to(:read, admin_note) }
      it { is_expected.to be_able_to(:create, admin_note) }
      it { is_expected.to_not be_able_to(:update, admin_note) }
    end

    context "accessed by field admins" do
      let(:account) { build :field_admin, field_org: field_org }

      it { is_expected.to be_able_to(:read, admin_note) }
      it { is_expected.not_to be_able_to(:update, admin_note) }
    end

    context "accessed by field dispatchers" do
      let(:account) { build :field_dispatcher, field_org: field_org }

      it { is_expected.not_to be_able_to(:read, admin_note) }
      it { is_expected.not_to be_able_to(:update, admin_note) }
    end

    context "accessed by field providers" do
      let(:account) { build :field_provider, field_org: field_org }

      it { is_expected.not_to be_able_to(:read, admin_note) }
      it { is_expected.not_to be_able_to(:update, admin_note) }
    end

    context "accessed by external accounts" do
      let(:account) { build :external_account }

      it { is_expected.not_to be_able_to(:read, admin_note) }
      it { is_expected.not_to be_able_to(:update, admin_note) }
    end
  end

  context "field orgs" do
    context "accessed by super admin" do
      let(:user) { create(:super_admin_user) }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, field_org) }
      end
    end

    context "accessed by a medarrive_admin" do
      let(:account) { create :medarrive_admin }

      it { is_expected.to be_able_to(:read, field_org) }
      it { is_expected.to be_able_to(:update, field_org) }
      it { is_expected.to be_able_to(:read, other_field_org) }
    end

    context "accessed by field admins" do
      let(:account) { build :field_admin, field_org: field_org }

      it { is_expected.to be_able_to(:read, field_org) }
      it { is_expected.to be_able_to(:update, field_org) }
      it { is_expected.not_to be_able_to(:read, other_field_org) }
    end

    context "accessed by field dispatchers" do
      let(:account) { build :field_dispatcher, field_org: field_org }

      it { is_expected.to be_able_to(:read, field_org) }
      it { is_expected.not_to be_able_to(:update, field_org) }
      it { is_expected.not_to be_able_to(:read, other_field_org) }
    end

    context "accessed by field providers" do
      let(:account) { build :field_provider, field_org: field_org }

      it { is_expected.to be_able_to(:read, field_org) }
      it { is_expected.not_to be_able_to(:update, field_org) }
      it { is_expected.not_to be_able_to(:read, other_field_org) }
    end

    context "accessed by external accounts" do
      let(:account) { build :external_account }

      it { is_expected.not_to be_able_to(:read, field_org) }
      it { is_expected.not_to be_able_to(:update, field_org) }
      it { is_expected.not_to be_able_to(:read, other_field_org) }
    end
  end

  context "demand partners" do
    let(:demand_partner) { create :demand_partner }

    context "accessed by super admin" do
      let(:user) { create(:super_admin_user) }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, demand_partner) }
      end
    end

    context "accessed by a medarrive_admin" do
      let(:account) { create :medarrive_admin }

      it { is_expected.to be_able_to(:read, demand_partner) }
      it { is_expected.to be_able_to(:update, demand_partner) }

      it "can not delete", skip: "Temporary manage permisions" do
        is_expected.to_not be_able_to(:destroy, demand_partner)
      end
    end

    context "accessed by other users" do
      let(:account) { create :field_admin }

      it { is_expected.to_not be_able_to(:read, demand_partner) }
    end
  end

  context "availability" do
    context "accessed by coordinator" do
      let(:account) { create :demand_coordinator }

      it { is_expected.to be_able_to(:read, :availability) }
    end

    context "accessed by field admin" do
      let(:account) { create :field_admin }

      it { is_expected.to be_able_to(:read, :availability) }
    end

    context "accessed by MedArrive admin" do
      let(:account) { create :medarrive_admin }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, :availability) }
      end
    end
  end

  context "appointments" do
    let(:appointment) { create :appointment }

    context "accessed by super admin" do
      let(:user) { create(:super_admin_user) }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, appointment) }
      end
    end

    context "accessed by medarrive admin" do
      let(:account) { create :medarrive_admin }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, appointment) }
      end
    end

    context "accessed by medarrive customer support" do
      let(:account) { create :medarrive_customer_support }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, appointment) }
      end
    end

    context "accessed by medarrive clinical operations" do
      let(:account) { create :medarrive_clinical_operation }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, appointment) }
      end
    end

    context "accessed by other users" do
      let(:account) { create :field_admin }

      it { is_expected.not_to be_able_to(:read, appointment) }
    end
  end

  context "primary_care_physicians" do
    let(:primary_care_physician) { create :primary_care_physician }

    context "accessed by super admin" do
      let(:account) { create(:super_admin_user).account }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, primary_care_physician) }
      end
    end

    context "accessed by medarrive admin" do
      let(:account) { create :medarrive_admin }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, primary_care_physician) }
      end
    end

    context "accessed by medarrive customer support" do
      let(:account) { create :medarrive_customer_support }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, primary_care_physician) }
      end
    end

    context "accessed by medarrive clinical operations" do
      let(:account) { create :medarrive_clinical_operation }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, primary_care_physician) }
      end
    end

    context "accessed by external accounts" do
      let(:account) { build :external_account }

      it { is_expected.to be_able_to(:read, primary_care_physician) }
      it { is_expected.to be_able_to(:show, primary_care_physician) }
    end

    context "accessed by field org users" do
      context "accessed by field admin" do
        let(:account) { build :field_admin }

        it { is_expected.not_to be_able_to(:read, primary_care_physician) }
        it { is_expected.to be_able_to(:show, primary_care_physician) }
      end

      context "accessed by field dispatcher" do
        let(:account) { build :field_dispatcher }

        it { is_expected.not_to be_able_to(:read, primary_care_physician) }
        it { is_expected.to be_able_to(:show, primary_care_physician) }
      end

      context "accessed by field provider" do
        let(:account) { build :field_provider }

        it { is_expected.to be_able_to(:read, primary_care_physician) }
        it { is_expected.to be_able_to(:show, primary_care_physician) }
      end
    end
  end

  context "patient prospects" do
    let(:demand_partner) { build :demand_partner }
    let(:patient_prospect) { build :patient_prospect, demand_partner: demand_partner }
    let(:other_patient_prospect) { build :patient_prospect }

    context "accessed by super admin" do
      let(:account) { create(:super_admin_user).account }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient_prospect) }
        it { is_expected.to be_able_to(function, other_patient_prospect) }
      end
    end

    context "accessed by medarrive admin" do
      let(:account) { create :medarrive_admin }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient_prospect) }
        it { is_expected.to be_able_to(function, patient_prospect) }
        it { is_expected.to be_able_to(function, patient_prospect) }

        it { is_expected.to be_able_to(function, other_patient_prospect) }
        it { is_expected.to be_able_to(function, other_patient_prospect) }
        it { is_expected.to be_able_to(function, other_patient_prospect) }
      end
    end

    context "accessed by demand partner" do
      let(:account) { create :demand_coordinator, demand_partner: demand_partner }

      it { is_expected.to be_able_to(:create, patient_prospect) }

      it { is_expected.to_not be_able_to(:create, other_patient_prospect) }
    end
  end

  context "visit requests" do
    let(:demand_partner) { create :demand_partner }
    let(:visit_request) { build :visit_request, transient_demand_partner: demand_partner }
    let(:other_visit_request) { build :visit_request }

    context "accessed by medarrive admin" do
      let(:account) { build :medarrive_admin }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, visit_request) }
      end
    end

    context "accessed by demand coordinators" do
      let(:account) { build :demand_coordinator, demand_partner: demand_partner }

      it { is_expected.to be_able_to(:read, visit_request) }
      it { is_expected.to be_able_to(:create, visit_request) }
      it { is_expected.not_to be_able_to(:read, other_visit_request) }
      it { is_expected.not_to be_able_to(:create, other_visit_request) }
    end
  end

  #########################################

  # User-centric approach

  context "medarrive admin user" do
    let(:account) { create :medarrive_admin }

    context "=> users & accounts" do
      let(:medarrive_user_account) { create :medarrive_admin }
      let(:other_user_account) { create :field_admin }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, medarrive_user_account) }
        it { is_expected.to be_able_to(function, medarrive_user_account.user) }
      end

      it { is_expected.to be_able_to(:read, other_user_account) }
      it { is_expected.to_not be_able_to(:read, other_user_account.user) }
    end

    context "=> field orgs" do
      let(:field_org) { create :field_org }

      it { expect(subject.can?(:create, FieldOrg)).to be true }
      it { is_expected.to be_able_to(:read, field_org) }
      it { is_expected.to be_able_to(:update, field_org) }

      it "can not delete", skip: "Temporary manage permisions" do
        is_expected.to_not be_able_to(:destroy, field_org)
      end
    end

    context "=> demand partners" do
      let(:demand_partner) { create :demand_partner }

      it { expect(subject.can?(:create, DemandPartner)).to be true }
      it { is_expected.to be_able_to(:read, demand_partner) }
      it { is_expected.to be_able_to(:update, demand_partner) }

      it "can not delete", skip: "Temporary manage permisions" do
        is_expected.to_not be_able_to(:destroy, demand_partner)
      end
    end

    context "=> patients, appointments, and associated clinical or non-clinical data" do
      let(:patient) { create :patient, :with_address, :with_insurance, :with_primary_care_physician, :with_pharmacy }
      let(:appointment) { create :appointment }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient) }
        it { is_expected.to be_able_to(function, patient.address) }

        it { is_expected.to be_able_to(function, patient.primary_care_physician) }
        it { is_expected.to be_able_to(function, patient.pharmacies.first) }
        it { is_expected.to be_able_to(function, patient.pharmacies.first.address) }
        it { is_expected.to be_able_to(function, patient.insurances.first) }

        it { is_expected.to be_able_to(function, appointment) }
        it { is_expected.to be_able_to(function, appointment.address) }
      end
    end

    context "=> admin notes" do
      let(:admin_note) { create :admin_note }

      it { expect(subject.can?(:create, AdminNote)).to be true }
      it { is_expected.to be_able_to(:read, admin_note) }

      it { is_expected.to_not be_able_to(:update, admin_note) }
      it { is_expected.to_not be_able_to(:destroy, admin_note) }
    end
  end

  context "medarrive customer support user" do
    let(:account) { create :medarrive_customer_support }

    context "=> users & accounts" do
      let(:medarrive_user_account) { create :medarrive_customer_support }
      let(:other_user_account) { create :field_admin }

      %i[create update read].each do |function|
        it { is_expected.to_not be_able_to(function, medarrive_user_account) }
        it { is_expected.to_not be_able_to(function, medarrive_user_account.user) }
      end

      it { is_expected.to_not be_able_to(:read, other_user_account) }
      it { is_expected.to_not be_able_to(:read, other_user_account.user) }
    end

    context "=> field orgs" do
      let(:field_org) { create :field_org }

      it { expect(subject.can?(:create, FieldOrg)).to be false }
      it { is_expected.to_not be_able_to(:read, field_org) }
      it { is_expected.to_not be_able_to(:update, field_org) }

      it { is_expected.to_not be_able_to(:destroy, field_org) }
    end

    context "=> demand partners" do
      let(:demand_partner) { create :demand_partner }

      it { expect(subject.can?(:create, DemandPartner)).to be false }
      it { is_expected.to_not be_able_to(:read, demand_partner) }
      it { is_expected.to_not be_able_to(:update, demand_partner) }

      it { is_expected.to_not be_able_to(:destroy, demand_partner) }
    end

    context "=> patients, appointments, and associated clinical or non-clinical data" do
      let(:patient) { create :patient, :with_address, :with_insurance, :with_primary_care_physician, :with_pharmacy }
      let(:appointment) { create :appointment }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient) }
        it { is_expected.to be_able_to(function, patient.address) }

        it { is_expected.to be_able_to(function, patient.primary_care_physician) }
        it { is_expected.to be_able_to(function, patient.pharmacies.first) }
        it { is_expected.to be_able_to(function, patient.pharmacies.first.address) }
        it { is_expected.to be_able_to(function, patient.insurances.first) }

        it { is_expected.to be_able_to(function, appointment) }
        it { is_expected.to be_able_to(function, appointment.address) }
      end
    end

    context "=> admin notes" do
      let(:admin_note) { create :admin_note }

      it { expect(subject.can?(:create, AdminNote)).to be true }
      it { is_expected.to be_able_to(:read, admin_note) }

      it { is_expected.to_not be_able_to(:update, admin_note) }
      it { is_expected.to_not be_able_to(:destroy, admin_note) }
    end
  end

  context "medarrive clinical operations user" do
    let(:account) { create :medarrive_clinical_operation }

    context "=> users & accounts" do
      let(:medarrive_user_account) { create :medarrive_clinical_operation }
      let(:other_user_account) { create :field_admin }

      %i[create update read].each do |function|
        it { is_expected.to_not be_able_to(function, medarrive_user_account) }
        it { is_expected.to_not be_able_to(function, medarrive_user_account.user) }
      end

      it { is_expected.to_not be_able_to(:read, other_user_account) }
      it { is_expected.to_not be_able_to(:read, other_user_account.user) }
    end

    context "=> field orgs" do
      let(:field_org) { create :field_org }

      it { expect(subject.can?(:create, FieldOrg)).to be false }
      it { is_expected.to_not be_able_to(:read, field_org) }
      it { is_expected.to_not be_able_to(:update, field_org) }

      it { is_expected.to_not be_able_to(:destroy, field_org) }
    end

    context "=> demand partners" do
      let(:demand_partner) { create :demand_partner }

      it { expect(subject.can?(:create, DemandPartner)).to be false }
      it { is_expected.to_not be_able_to(:read, demand_partner) }
      it { is_expected.to_not be_able_to(:update, demand_partner) }

      it { is_expected.to_not be_able_to(:destroy, demand_partner) }
    end

    context "=> patients, appointments, and associated clinical or non-clinical data" do
      let(:patient) { create :patient, :with_address, :with_insurance, :with_primary_care_physician, :with_pharmacy }
      let(:appointment) { create :appointment }

      %i[create update read].each do |function|
        it { is_expected.to be_able_to(function, patient) }
        it { is_expected.to be_able_to(function, patient.address) }

        it { is_expected.to be_able_to(function, patient.primary_care_physician) }
        it { is_expected.to be_able_to(function, patient.pharmacies.first) }
        it { is_expected.to be_able_to(function, patient.pharmacies.first.address) }
        it { is_expected.to be_able_to(function, patient.insurances.first) }

        it { is_expected.to be_able_to(function, appointment) }
        it { is_expected.to be_able_to(function, appointment.address) }
      end
    end

    context "=> admin notes" do
      let(:admin_note) { create :admin_note }

      it { expect(subject.can?(:create, AdminNote)).to be true }
      it { is_expected.to be_able_to(:read, admin_note) }

      it { is_expected.to_not be_able_to(:update, admin_note) }
      it { is_expected.to_not be_able_to(:destroy, admin_note) }
    end
  end

  context "field admin user" do
    let(:field_org) { create :field_org }
    let(:account) { create :field_admin, field_org: field_org }

    let(:medarrive_user_account) { create :medarrive_admin }
    let(:admin_note) { create :admin_note, creator: user }
    let(:other_admin_note) { create :admin_note }

    let(:other_field_org) { create :field_org }

    let(:field_provider) { create :field_provider, field_org: field_org }
    let(:other_field_provider) { create :field_provider, field_org: other_field_org }

    context "=> admin notes" do
      context "created by the user" do
        it { is_expected.to be_able_to(:read, admin_note) }
        it { is_expected.to be_able_to(:update, admin_note) }
      end

      context "created by other users" do
        it { is_expected.to be_able_to(:read, other_admin_note) }
        it { is_expected.to_not be_able_to(:update, other_admin_note) }
      end
    end

    context "=> field orgs" do
      context "matching user's field org" do
        it { is_expected.to be_able_to(:read, field_org) }
        it { is_expected.to be_able_to(:update, field_org) }

        # TODO: This is not a valid permission in the future
        # Field Admins should NOT be able to destroy Field org
        # it { is_expected.to_not be_able_to(:destroy, field_org) }
      end

      context "not matching user's field org" do
        it { is_expected.to_not be_able_to(:read, other_field_org) }
      end
    end
  end

  describe ".lookup_role" do
    it "returns the class for existing roles" do
      expect(Ability.lookup_role("FieldProvider")).to eq FieldProvider
    end

    it "throws an error when the role does not exist" do
      expect { Ability.lookup_role("nonsense_madeup_role") }.to raise_error(/does not exist/)
    end
  end
end
