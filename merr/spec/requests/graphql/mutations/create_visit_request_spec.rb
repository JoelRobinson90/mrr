# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "GraphQL / Create Visit Request", type: :request do
  before do
    sign_in current_user
  end

  let(:demand_coordinator_user) { create(:demand_coordinator_user) }
  let(:demand_partner) { demand_coordinator_user.account.demand_partner }
  let(:other_demand_partner) { create :demand_partner }
  let(:admin_user) { create(:medarrive_admin_user) }

  let!(:program) { create :program, demand_partner: demand_partner }
  let!(:other_program) { create :program, demand_partner: other_demand_partner }

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
        addressLineOne: "655 W Church St",
        city:           "Orlando",
        state:          "FL",
        zipcode:        "32805"
      },
      userAttributes:      {
        email: user_attrs[:email]
      }
    }
  end

  describe "createVisitRequest mutation" do
    query = <<-GRAPHQL
      mutation ($attributes: CreateVisitRequestParams!) {
        createVisitRequest(input: { attributes: $attributes }) {
          visitRequest {
            id
          }
          errors
        }
      }
    GRAPHQL

    context "with demand coordinator user" do
      let(:current_user) { demand_coordinator_user }

      it "creates a new visit request" do
        expect do
          post_graphql_request(
            query:     query,
            variables: {
              attributes: {
                patient: patient_params
              }
            }
          )
        end.to change { VisitRequest.count }.by(1)
        body = get_graphql_response

        visit_request = VisitRequest.find(body["data"]["createVisitRequest"]["visitRequest"]["id"])
        patient = visit_request.patient
        expect(patient.first_name).to eq patient_params[:firstName]
        expect(patient.medical_record_number).to eq patient_params[:medicalRecordNumber]
      end

      it "can't create a new visit request with a patient with a different demand partner" do
        expect do
          post_graphql_request(
            query:     query,
            variables: {
              attributes: {
                patient: patient_params.merge(demandPartnerId: other_demand_partner.id)
              }
            }
          )
        end.not_to change { VisitRequest.count }
        body = get_graphql_response

        expect(body["data"]["createVisitRequest"]["visitRequest"]).to be_nil
      end
    end
  end
end
