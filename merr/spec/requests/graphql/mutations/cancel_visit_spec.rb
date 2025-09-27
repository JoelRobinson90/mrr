# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL / Cancel Visit Request", type: :request do
  let!(:visit) { create :visit }
  let!(:cancel_code) { create :cancel_code }

  before do
    sign_in create(:user)
  end

  query = <<-GRAPHQL
    mutation ($id: ID, $maId: ID, $cancelCodeId: ID!) {
      cancelVisit(input: {id: $id, maId: $maId, cancelCodeId: $cancelCodeId}) {
        visit {
          id
          canceled
          cancelCodeId
        }
        errors
      }
    }
  GRAPHQL

  context "authorized user" do
    before do
      allow_any_instance_of(Ability).to receive(:can?).with(:update, an_instance_of(Visit)) { true }
    end

    it "cancels visit by ID" do
      post_graphql_request(
        query:     query,
        variables: {
          id:           visit.id,
          cancelCodeId: cancel_code.id
        }
      )
      body = get_graphql_response

      expect(body["data"]["cancelVisit"]["visit"]["id"]).to eq visit.id.to_s
      expect(body["data"]["cancelVisit"]["visit"]["canceled"]).to eq true

      visit.reload
      expect(visit.canceled).to eq true
      expect(visit.cancel_code_id).to eq cancel_code.id
    end

    it "cancels visit by external ID" do
      post_graphql_request(
        query:     query,
        variables: {
          maId:         visit.ma_id,
          cancelCodeId: cancel_code.id
        }
      )
      body = get_graphql_response

      expect(body["data"]["cancelVisit"]["visit"]["id"]).to eq visit.id.to_s
      expect(body["data"]["cancelVisit"]["visit"]["canceled"]).to eq true

      visit.reload
      expect(visit.canceled).to eq true
      expect(visit.cancel_code_id).to eq cancel_code.id
    end
  end

  context "unauthorized user" do
    before do
      allow_any_instance_of(Ability).to receive(:can?).with(:update, an_instance_of(Visit)) { false }
    end

    it "does not cancel" do
      post_graphql_request(
        query:     query,
        variables: {
          id:           visit.id,
          cancelCodeId: cancel_code.id
        }
      )
      body = get_graphql_response(allow_errors: true)

      expect(body["data"]["cancelVisit"]["visit"]).to eq nil

      visit.reload
      expect(visit.canceled).to eq false
      expect(visit.cancel_code_id).to eq nil
    end
  end
end
