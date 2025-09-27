# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Breadcrumbs", type: :request do
  let(:current_user) { create(:medarrive_admin).user }

  before do
    sign_in current_user
  end

  describe "With repeats and cycles" do
    let(:patient) { create(:patient, first_name: "test1", middle_initial: "a", last_name: "test2") }
    it "tracks history" do
      get admin_patient_path(patient.id)

      extended_breadcrumbs = [{text: "test1 a test2", href: "/admin/patients/#{patient.id}"}]

      expect(extended_breadcrumbs).to eq(session[:breadcrumbs].map(&:symbolize_keys))
    end
  end
end
