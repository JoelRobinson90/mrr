# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "GraphQL / Alayacare Visit Queries", type: :request do
  before do
    sign_in current_user
  end

  let(:demand_coordinator_user) { create(:demand_coordinator_user) }
  let(:demand_partner) { demand_coordinator_user.account.demand_partner }
  let(:admin_user) { create(:medarrive_admin_user) }

  # NOTE: matches patient ID in VCR response
  let!(:patient) { create(:patient, medical_record_number: "31", demand_partner: demand_partner) }
  let!(:other_patient) { create(:patient, medical_record_number: "26") }

  describe "getAlayacareVisits query" do
    query = <<-GRAPHQL
      query($date: String!) {
        getAlayacareVisits(date: $date) {
          fpId
          location
          startTime
          endTime
          demandPartnerId
          patient {
            id
            firstName
          }
        }
      }
    GRAPHQL

    context "with medarrive admin user" do
      let(:current_user) { admin_user }

      it "returns all visits in a day" do
        post_graphql_request(
          query:     query,
          variables: {date: "2022-01-12"}
        )
        body = get_graphql_response

        expect(body["data"]["getAlayacareVisits"]).to have(21).items

        expect(body["data"]["getAlayacareVisits"][0]["patient"]["id"]).to eq patient.id.to_s
        expect(body["data"]["getAlayacareVisits"][0]["demandPartnerId"]).to eq demand_partner.id.to_s
        expect(body["data"]["getAlayacareVisits"][6]["patient"]["id"]).to eq other_patient.id.to_s
      end
    end

    context "with demand coordinator user" do
      let(:current_user) { demand_coordinator_user }

      it "returns all visits in a day belonging to the user's demand partner" do
        post_graphql_request(
          query:     query,
          variables: {date: "2022-01-12"}
        )
        body = get_graphql_response

        expect(body["data"]["getAlayacareVisits"]).to have(2).items

        expect(body["data"]["getAlayacareVisits"][0]["patient"]["id"]).to eq patient.id.to_s
        expect(body["data"]["getAlayacareVisits"][0]["demandPartnerId"]).to eq demand_partner.id.to_s
        expect(body["data"]["getAlayacareVisits"][1]["demandPartnerId"]).to eq demand_partner.id.to_s
      end
    end
  end
end
