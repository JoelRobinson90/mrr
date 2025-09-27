# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL / Cancel Code Queries", type: :request do
  before do
    sign_in current_user
  end
  let(:current_user) { create(:medarrive_admin_user) }

  describe "getCurrentUser query" do
    context "MedarriveAdmin user" do
      it "returns user account interface fields" do
        query = <<-GRAPHQL
          query {
            getCurrentUser {
              id
              account {
                __typename
                id
                firstName
                lastName
              }
            }
          }
        GRAPHQL

        post_graphql_request(query: query)
        body = get_graphql_response

        user = body["data"]["getCurrentUser"]
        expect(user["id"]).to eq current_user.id.to_s
        expect(user["account"]).to eq({
                                        "__typename" => "MedarriveAdmin",
                                        "id"         => current_user.account.id.to_s,
                                        "firstName"  => current_user.account.first_name,
                                        "lastName"   => current_user.account.last_name
                                      })
      end

      # This tests legacy query format
      it "returns interface fields separated by account type" do
        query = <<-GRAPHQL
          query {
            getCurrentUser {
              id
              account {
                __typename
                id

                ... on MedarriveAdmin {
                  firstName
                  lastName
                }
              }
            }
          }
        GRAPHQL

        post_graphql_request(query: query)
        body = get_graphql_response

        user = body["data"]["getCurrentUser"]
        expect(user["id"]).to eq current_user.id.to_s
        expect(user["account"]).to eq({
                                        "__typename" => "MedarriveAdmin",
                                        "id"         => current_user.account.id.to_s,
                                        "firstName"  => current_user.account.first_name,
                                        "lastName"   => current_user.account.last_name
                                      })
      end
    end

    context "account type with extra fields" do
      let!(:current_user) { create(:demand_coordinator_user) }

      it "selects extra fields" do
        query = <<-GRAPHQL
          query {
            getCurrentUser {
              id
              account {
                __typename
                id
                firstName
          #{'      '}
                ... on MedarriveAdmin {
                  lastName
                }

                ... on DemandCoordinator {
                  demandPartner {
                    name
                  }
                }
              }
            }
          }
        GRAPHQL

        post_graphql_request(query: query)
        body = get_graphql_response

        user = body["data"]["getCurrentUser"]
        expect(user["id"]).to eq current_user.id.to_s
        expect(user["account"]).to eq({
                                        "__typename"    => "DemandCoordinator",
                                        "id"            => current_user.account.id.to_s,
                                        "firstName"     => current_user.account.first_name,
                                        # lastName intentionally missing
                                        "demandPartner" => {
                                          "name" => current_user.account.demand_partner.name
                                        }
                                      })
      end
    end

    context "made up account type" do
      let(:current_user) { create(:external_account_user) }

      it "returns account info under a default type" do
        query = <<-GRAPHQL
          query {
            getCurrentUser {
              id
              accountType
              account {
                __typename
                id
                firstName
                lastName
              }
            }
          }
        GRAPHQL

        post_graphql_request(query: query)
        body = get_graphql_response

        user = body["data"]["getCurrentUser"]
        expect(user["id"]).to eq current_user.id.to_s
        expect(user["accountType"]).to eq "ExternalAccount"
        expect(user["account"]).to eq({
                                        "__typename" => "DefaultUserAccount",
                                        "id"         => current_user.account.id.to_s,
                                        "firstName"  => current_user.account.first_name,
                                        "lastName"   => current_user.account.last_name
                                      })
      end
    end
  end
end
