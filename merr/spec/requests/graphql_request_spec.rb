require "rails_helper"

current_user_query = <<~GRAPHQL
query {
  getCurrentUser {
    id
    email
  }
}
GRAPHQL

RSpec.describe "GraphQL", type: :request do
  let(:user) { create(:super_admin_user) }

  describe "POST /graphql" do
    context "signed in user" do
      before do
        sign_in user
      end

      it "returns a successful payload" do
        params = { query: current_user_query }.to_json
        post graphql_path, params: params, headers: { "content-type": "application/json" }
        expect(response).to have_http_status(:success)

        body = JSON.parse(response.body)
        puts body
        expect(body.dig("data", "getCurrentUser", "id")).to eq(user.id.to_s)
      end
    end

    context "no signed in user" do
      it "returns an unauthorized error" do
        post graphql_path, params: {
          query: current_user_query
        }.to_json
        expect(response).to have_http_status(:unauthorized)

        body = JSON.parse(response.body)
        expect(body.dig("data", "getCurrentUser", "id")).to be_nil
      end
    end
  end

  describe "POST /graphql_jwt" do
    let(:valid_token) do
      "eyJraWQiOiJUaEJXcFRhSkJUNUczSWtJZWRNVmF2eWU4eElIMV95M2MtdXBNbjFoX1JBIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmw5azZHX01LZEVQX3BWOXdScm5CdVRGYktrY2RoN2MzSmVRdF8xbUhjTjQub2FyZG9oczI2TkJiSHBBcEY2OTYiLCJpc3MiOiJodHRwczovL21lZGFycml2ZS5va3RhLmNvbSIsImF1ZCI6Imh0dHBzOi8vbWVkYXJyaXZlLm9rdGEuY29tIiwic3ViIjoiZXJpa0BtZWRhcnJpdmUuY29tLnBvYyIsImlhdCI6MTY2ODUyNjIxNiwiZXhwIjoxNjY4NTI5ODE2LCJjaWQiOiIwb2Eydzl1cDBmTTc0WlhZYTY5NyIsInVpZCI6IjAwdThybDdhcjJZYlJvZWh2Njk2Iiwic2NwIjpbIm9wZW5pZCIsImVtYWlsIiwicHJvZmlsZSIsIm9mZmxpbmVfYWNjZXNzIl0sImF1dGhfdGltZSI6MTY2ODUyNjIxNX0.jNA2S7YMayTadSTPquwhKltnHc3gpi-mNTVoLGsCorwCMFGvmddisfKXpyLL_DoP5jZt7KAPO-tnjRna8eM4ZuPNta8rR3jYfbP4VS0YOM9KPw4m35BSUryZ8AUIldROkOP-1YpujHmL9ZvLVqJ0JQQ1BQkafX4UPIuSasC-xDyp6cEiiqQzwE5zgy2nLEej4Esj5-IDBMT0xcF3WLTmZOjbKRvzqikjB_PmypU1hgHxF2bQmD46CpII8sMRuRlIzwSBStiYSZoVFI50m_F49OiiFNV9Zq7feEbHeNZ7aPj-upopuXblTBLOaSxxV91tGXe1gWHlDJRnkq3ZIJn2RQ"
    end

    context "valid jwt user" do
      before do
        GraphqlController.any_instance.stub(:valid_jwt?) { true }
        GraphqlController.any_instance.stub(:current_user) { user }
      end

      it "returns a successful payload" do
        params = { query: current_user_query }.to_json
        post graphql_jwt_path, params: params, headers: { "content-type": "application/json" }
        expect(response).to have_http_status(:success)

        body = JSON.parse(response.body)
        puts body
        expect(body.dig("data", "getCurrentUser", "id")).to eq(user.id.to_s)
      end
    end

    context "no valid jwt user" do
      it "returns an unauthorized error" do
        post graphql_jwt_path, params: {
          query: current_user_query
        }.to_json
        expect(response).to have_http_status(:unauthorized)

        body = JSON.parse(response.body)
        expect(body.dig("data", "getCurrentUser", "id")).to be_nil
      end
    end
  end
end
