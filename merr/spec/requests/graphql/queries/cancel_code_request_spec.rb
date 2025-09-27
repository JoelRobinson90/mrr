require "rails_helper"

RSpec.describe "GraphQL / Cancel Code Queries", type: :request do
  before do
    sign_in current_user
  end
  let(:current_user) { create(:medarrive_admin_user)}

  describe "getCancelCodes query" do
    let!(:code_v1) { create :cancel_code, alayacare_id: '123', athena_id: nil }
    let!(:code_v2) { create :cancel_code, alayacare_id: nil, athena_id: '456' }
    let!(:code_both) { create :cancel_code, alayacare_id: '879', athena_id: '0ab' }

    query = <<-GRAPHQL
      query {
        getCancelCodes {
          id
        }
      }
    GRAPHQL

    it "includes only v2 codes" do
      post_graphql_request(query: query)
      body = get_graphql_response

      returned_ids = body["data"]["getCancelCodes"].map { |code| code["id"].to_s }
      expect(returned_ids).not_to include code_v1.id.to_s
      expect(returned_ids).to include code_v2.id.to_s
      expect(returned_ids).to include code_both.id.to_s
    end
  end
end
