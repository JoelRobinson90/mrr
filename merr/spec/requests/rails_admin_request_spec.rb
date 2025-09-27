# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "Rails Admin", type: :request do
  before do
    sign_in current_user
  end

  describe "GET index" do
    context "when a super admin requests the page" do
      let!(:current_user) { create(:super_admin_user) }

      it "successfully renders the rails admin page" do
        get rails_admin_path

        expect(response.code).to eq("200")
      end
    end

    context "when any other user requests the page" do
      let!(:current_user) { create(:field_admin_user) }

      it "denies access from the rails admin page" do
        expect { get rails_admin_path }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
