module TempAuthToken
  extend ActiveSupport::Concern

  included do
    def sfdc_iframe_poc_auth_token
      EnvHelper.env_or_nil("SFDC_IFRAME_TEMP_AUTH_TOKEN")
    end

    # Override current_user to return a dummy user object if a temp auth token is used
    # If user is actually logged in, always use that user
    def current_user
      if allow_temp_auth_token? && temp_auth_token.present?
        super || temp_auth_token_user
      else
        super
      end
    end

    def temp_auth_token_user
      return nil unless allow_temp_auth_token?

      if sfdc_iframe_authorized?
        return User.new(
          email: "sfdc_temp_iframe_user@fake.com",
          account: MedarriveAdmin.new(first_name: "SFDC", last_name: "User")
        )
      end
    end

    def sfdc_iframe_authorized?
      allow_temp_auth_token? &&
        sfdc_iframe_poc_auth_token.present? &&
        temp_auth_token == sfdc_iframe_poc_auth_token
    end

    def temp_auth_token
      params[:temp_auth_token].presence || request.headers['HTTP_X_TEMP_AUTH_TOKEN']
    end
    helper_method :temp_auth_token

    def allow_temp_auth_token?
      !Rails.env.production? || EnvHelper.env_or_nil('HOST_ENV') == 'test'
    end
  end
end
