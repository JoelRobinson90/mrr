require "rails_helper"

RSpec.describe "GraphQL / JWT Auth", type: :request do
  let(:admin_user) { create(:medarrive_admin_user) }

  before do
    sign_in admin_user
  end

  describe "papertrail whodunnit" do
    let!(:visit) { create :visit, :v2 }
  
    it "is properly set to current user id" do
      query = <<-GRAPHQL
        mutation ($params: CreateVisitNoteParams!) {
          createVisitNote(input: {
            visitNoteParams: $params
          }) {
            visitNote {
              id
              maId
              creatorId
              content
            }
            errors
          }
        }
      GRAPHQL

      post_graphql_request(
        query:     query,
        variables: {
          params: {
            visitMaId: visit.ma_id,
            content:   "Hope my user ID is in the version!"
          }
        }
      )

      whodunnit = visit.admin_notes.last.versions.last.whodunnit
      expect(whodunnit).not_to be_blank
      expect(whodunnit.to_s).to eq admin_user.id.to_s
    end
  end
end
