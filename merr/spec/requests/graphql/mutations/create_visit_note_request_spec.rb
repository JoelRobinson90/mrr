# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL / Create Visit Note Request", type: :request do
  let(:current_user) { create :medarrive_admin_user }
  let!(:visit) { create :visit, program: create(:program, v2: true) }

  let(:query) do
    <<-GRAPHQL
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
  end

  let(:perform_request) do
    post_graphql_request(
      query:     query,
      variables: {
        params: {
          visitMaId: visit.ma_id,
          content:   "Smooth visit"
        }
      }
    )
  end

  before do
    sign_in current_user
    Ability.any_instance.stub(:can?).with(:create, an_instance_of(AdminNote)) { ability }
  end

  describe "with ability" do
    let(:ability) { true }

    it "creates a note" do
      expect { perform_request }.to change(AdminNote, :count).by(1)
      body = get_graphql_response

      note_id = body["data"]["createVisitNote"]["visitNote"]["id"]
      note = AdminNote.find(note_id)

      expect(body["data"]["createVisitNote"]["errors"]).to be_blank
      expect(note).to have_attributes(
        ma_id:        body["data"]["createVisitNote"]["visitNote"]["maId"],
        creator_id:   current_user.id,
        content:      "Smooth visit",
        notable_type: "Visit",
        notable_id:   visit.id
      )
    end
  end

  describe "without ability" do
    let(:ability) { false }

    before do
      allow_any_instance_of(Ability).to receive(:can?).with(:create, an_instance_of(AdminNote)) { false }
    end

    it "does not create a new note" do
      expect { perform_request }.not_to change(AdminNote, :count)
      body = get_graphql_response
      expect(body["data"]["createVisitNote"]["visitNote"]).to be_nil
      expect(body["data"]["createVisitNote"]["errors"]).not_to be_blank
    end
  end
end
