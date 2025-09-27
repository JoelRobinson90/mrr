# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "GraphQL / Patient Queries", type: :request do
  before do
    sign_in current_user
  end

  let(:demand_coordinator_user) { create(:demand_coordinator_user) }
  let(:demand_partner) { demand_coordinator_user.account.demand_partner }
  let(:admin_user) { create(:medarrive_admin_user) }

  describe "getPatient query" do
    let!(:demand_partner_patient) { create :patient, demand_partner: demand_partner }
    let!(:other_patient) { create :patient }

    id_query = <<-GRAPHQL
      query($id: ID!) {
        getPatient(id: $id) {
          id
          firstName
        }
      }
    GRAPHQL

    ma_id_query = <<-GRAPHQL
      query($maId: ID!) {
        getPatient(maId: $maId) {
          id
          firstName
        }
      }
    GRAPHQL

    context "with medarrive admin user" do
      let(:current_user) { admin_user }

      it "returns a patient belonging to any demand partner" do
        post_graphql_request(
          query:     id_query,
          variables: {id: other_patient.id}
        )
        body = get_graphql_response

        expect(body["data"]["getPatient"]).to eq(
          "id"        => other_patient.id.to_s,
          "firstName" => other_patient.first_name
        )
      end

      it "returns a patient by MA ID" do
        post_graphql_request(
          query:     ma_id_query,
          variables: {maId: other_patient.ma_id}
        )
        body = get_graphql_response

        expect(body["data"]["getPatient"]).to eq(
          "id"        => other_patient.id.to_s,
          "firstName" => other_patient.first_name
        )
      end
    end

    context "with demand coordinator user" do
      let(:current_user) { demand_coordinator_user }

      it "returns a patient belonging to their demand partner" do
        post_graphql_request(
          query:     id_query,
          variables: {id: demand_partner_patient.id}
        )
        body = get_graphql_response

        expect(body["data"]["getPatient"]).to eq(
          "id"        => demand_partner_patient.id.to_s,
          "firstName" => demand_partner_patient.first_name
        )
      end

      it "does not return a patient belonging to another demand partner" do
        post_graphql_request(
          query:     id_query,
          variables: {id: other_patient.id}
        )
        body = get_graphql_response

        expect(body["data"]["getPatient"]).to be_nil
      end
    end
  end

  describe "getPatients query" do
    let!(:demand_partner_patients) { create_list(:patient, 3, demand_partner: demand_partner) }
    let!(:other_patients) { create_list(:patient, 5) }

    query = <<-GRAPHQL
      query($ids: [ID!]) {
        getPatients(ids: $ids) {
          id
          firstName
        }
      }
    GRAPHQL

    context "with medarrive admin user" do
      let(:current_user) { admin_user }

      it "returns all patients" do
        post_graphql_request(query: query)
        body = get_graphql_response

        received_ids = body["data"]["getPatients"].map {|patient| patient["id"] }
        demand_partner_patients.each {|patient| expect(received_ids).to include(patient.id.to_s) }
        other_patients.each {|patient| expect(received_ids).to include(patient.id.to_s) }
      end

      it "filters patients by id" do
        requested_ids = [demand_partner_patients[0].id, other_patients[0].id]
        post_graphql_request(query: query, variables: {ids: requested_ids})
        body = get_graphql_response

        expected_ids = requested_ids.map(&:to_s)
        received_ids = body["data"]["getPatients"].map {|patient| patient["id"] }
        expect(received_ids).to match_array(expected_ids)
      end
    end

    context "with demand coordinator user" do
      let(:current_user) { demand_coordinator_user }

      it "returns patients belonging to the user's demand partner" do
        post_graphql_request(query: query)
        body = get_graphql_response

        received_ids = body["data"]["getPatients"].map {|patient| patient["id"] }
        demand_partner_patients.each {|patient| expect(received_ids).to include(patient.id.to_s) }
        other_patients.each {|patient| expect(received_ids).to_not include(patient.id.to_s) }
      end

      it "filters patients by id" do
        requested_ids = [demand_partner_patients[0].id, other_patients[0].id]
        post_graphql_request(query: query, variables: {ids: requested_ids})
        body = get_graphql_response

        expected_ids = [demand_partner_patients[0].id.to_s]
        received_ids = body["data"]["getPatients"].map {|patient| patient["id"] }
        expect(received_ids).to match_array(expected_ids)
      end
    end
  end
end
