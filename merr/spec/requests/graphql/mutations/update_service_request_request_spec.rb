require "rails_helper"

RSpec.describe "GraphQL / Update Service Request", type: :request do
  let(:current_user) { create :medarrive_admin_user }
  let!(:visit) { create :visit, program: create(:program, v2: true) }

  let(:query) do
    <<-GRAPHQL
      mutation ($id: ID, $maId: ID, $params: UpdateServiceRequestParams!) {
        updateServiceRequest(input: {
          id: $id,
          maId: $maId,
          params: $params
        }) {
          serviceRequest {
            id
            maId
            status
            statusDetail
            refusalReason
          }
          errors
        }
      }
    GRAPHQL
  end

  let(:id) { nil }
  let(:ma_id) { nil }
  let(:ability) { true }

  let(:service_request) do
    create(:service_request, status: "scheduled", status_detail: nil, refusal_reason: nil)
  end

  let(:perform_request) do
    post_graphql_request(
      query:     query,
      variables: {
        id: id,
        maId: ma_id,
        params: {
          status: "refused",
          statusDetail: "some_detail",
          refusalReason: "Scared of needles"
        }
      }
    )
  end

  before do
    sign_in current_user
    Ability.any_instance.stub(:can?).with(:update, an_instance_of(ServiceRequest)) { ability }
  end

  shared_examples "service request update success" do
    it "updates the existing service request" do
      perform_request
      body = get_graphql_response.deep_symbolize_keys

      expect(body[:errors]).to be_blank
      expect(body[:data][:updateServiceRequest][:errors]).to be_blank
      expect(body[:data][:updateServiceRequest][:serviceRequest]).to eq(
        id: service_request.id.to_s,
        maId: service_request.ma_id.to_s,
        status: "refused",
        statusDetail: "some_detail",
        refusalReason: "Scared of needles"
      )

      service_request.reload
      expect(service_request).to have_attributes(
        status: "refused",
        status_detail: "some_detail",
        refusal_reason: "Scared of needles"
      )
    end
  end

  describe "with ability" do
    let(:ability) { true }

    describe "lookup by id" do
      let(:id) { service_request.id }

      include_examples "service request update success"
    end

    describe "lookup by ma_id" do
      let(:ma_id) { service_request.ma_id }

      include_examples "service request update success"
    end
  end

  describe "without ability" do
    let(:ability) { false }

    it "does not create a new note" do
      perform_request
      body = get_graphql_response.deep_symbolize_keys
      expect(body[:data][:updateServiceRequest][:serviceRequest]).to be_nil
      expect(body[:data][:updateServiceRequest][:errors]).not_to be_blank
    end
  end
end
