# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe "Admin::Tags", type: :request do
  let!(:current_user) { create(:medarrive_admin).user }

  let!(:tag1) { create(:tag, name: "tag1", group: "Appointment") }
  let!(:tag2) { create(:tag, name: "tag2", group: "Patient") }
  let!(:tag3) { create(:tag, name: "tag3", group: "Patient") }

  before do
    sign_in current_user
  end

  describe "GET index" do
    it "successfully renders the react TagIndexPage" do
      get admin_tags_path

      expect(response).to render_template("layouts/admin")
      expect(response.body).to include('data-react-class="TagIndexPage"')

      expect(assigns(:tags).length).to eq(1)
    end

    describe "called with patient group" do
      it "only shows patient tags" do
        get admin_tags_path(group: "Patient")
        expect(assigns(:tags).length).to eq(2)
      end
    end
  end

  describe "GET show" do
    it "successfully renders the react TagShowPage" do
      get admin_tag_path(tag1)

      expect(response).to render_template("layouts/admin")
      expect(response.body).to include('data-react-class="TagShowPage"')

      expect(assigns(:tag)).to eq(tag1)
    end
  end

  describe "PUT update" do
    it "successfully updates tag" do
      params = {
        tag: {
          name: "NEW"
        }
      }
      put admin_tag_path(tag1), params: params

      expect(response).to redirect_to(admin_tag_path(tag1))

      tag1.reload
      expect(tag1.name).to eq("NEW")
    end
  end
end
