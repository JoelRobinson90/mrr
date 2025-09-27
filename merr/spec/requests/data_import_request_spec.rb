# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "DataImports", type: :request do
  before do
    sign_in current_user
  end

  describe "GET /new_data_import" do
    context "when a super admin requests page" do
      let!(:current_user) { create(:super_admin_user) }
      it "returns http success" do
        get "/data_import/new_data_import"
        expect(response).to have_http_status(:success)
      end
    end
  end
end
