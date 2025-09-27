# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def oktaoauth
      @user = User.from_auth_user(
        AuthUser.from_omniauth_callback(request.env["omniauth.auth"])
      )

      unless @user.persisted?
        redirect_to root_path, alert: "Could not find or create user: #{@user.errors.full_messages.to_sentence}"
        return
      end

      # Log in to devise
      sign_in(@user)

      # Make Okta remember login status, even though this isn't actually used by our system.
      session[:oktastate] = request.env["omniauth.auth"]["uid"]

      redirect_to root_path
    end
  end
end
