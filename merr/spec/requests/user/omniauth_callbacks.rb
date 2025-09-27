# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User::OmniauthCallbacks", type: :request do
  describe "POST users/omniauth_callbacks" do
    it "does not validate" do
      get user_oktaoauth_omniauth_callback_path

      expect(response["location"]).to eq("http://www.example.com/users/sign_in")
      expect(flash[:alert]).to eq('Could not authenticate you from Oktaoauth because "Csrf detected".')
    end
  end
end
