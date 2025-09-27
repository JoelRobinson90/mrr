# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "GraphQL / Create Patient", type: :request do
  before do
    sign_in current_user
  end

  let(:demand_coordinator_user) { create(:demand_coordinator_user) }
  let(:demand_partner) { demand_coordinator_user.account.demand_partner }
  let(:admin_user) { create(:medarrive_admin_user) }

  let!(:patient_params) do
    patient_attrs = FactoryBot.attributes_for(:patient)
    address_attrs = FactoryBot.attributes_for(:address)
    user_attrs = FactoryBot.attributes_for(:user)
    {
      demandPartnerId:     demand_partner.id,
      firstName:           patient_attrs[:first_name],
      lastName:            patient_attrs[:last_name],
      medicalRecordNumber: patient_attrs[:medical_record_number],
      dateOfBirth:         patient_attrs[:date_of_birth],
      phoneNumber:         patient_attrs[:phone_number],
      consentToText:       patient_attrs[:consent_to_text],
      sex:                 patient_attrs[:sex],
      preferredLanguage:   patient_attrs[:preferred_language],
      addressAttributes:   {
        state:          address_attrs[:state],
        addressLineOne: address_attrs[:address_line_one],
        addressLineTwo: address_attrs[:address_line_two],
        city:           address_attrs[:city],
        zipcode:        address_attrs[:zipcode],
        county:         address_attrs[:county]
      },
      userAttributes:      {
        email: user_attrs[:email]
      }
    }
  end

  describe "createPatient mutation" do
    query = <<-GRAPHQL
      mutation ($patient: CreatePatientParams!) {
        createPatient(input: { attributes: $patient }) {
          patient {
            id
            firstName
          }
          errors
        }
      }
    GRAPHQL

    context "with demand coordinator user" do
      let(:current_user) { demand_coordinator_user }

      it "creates a new patient with its own demand partner" do
        expect do
          post_graphql_request(
            query:     query,
            variables: {patient: patient_params}
          )
        end.to change { Patient.count }.by(1)
        body = get_graphql_response

        patient = Patient.find(body["data"]["createPatient"]["patient"]["id"])
        expect(patient.first_name).to eq patient_params[:firstName]
      end

      it "can't create a new patient with another demand partner" do
        other_demand_partner = create :demand_partner
        expect do
          post_graphql_request(
            query:     query,
            variables: {patient: patient_params.merge(demandPartnerId: other_demand_partner.id)}
          )
        end.not_to change { Patient.count }
        body = get_graphql_response

        expect(body["data"]["createPatient"]["patient"]).to be_nil
      end
    end
  end
end
