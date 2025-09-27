# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # DELETE /resource/sign_out
    def destroy
      sign_out
      redirect_to "#{EnvHelper.env_or_error('OKTA_URL')}/login/signout"
    end
  end
end
