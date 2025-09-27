module Okta
  class GetUserInfo < ApplicationService
    attr_reader :access_token, :cache, :force

    MAX_REMOTE_CACHE_TIME = 1.minute

    def initialize(access_token, force: false)
      @access_token = access_token
      @force = force
    end

    def call
      return OpenStruct.new(success?: false, error: "Token missing") if access_token.blank?
      return OpenStruct.new(success?: false, error: "Token invalid") if decoded_token.blank?
      return OpenStruct.new(success?: false, error: "Token expired") if token_expired?

      Rails.cache.fetch(cache_key, expires_in: cache_exp_in, force: force) { fetch_user_info }
    end

    private

    def fetch_user_info
      begin
        response = RestClient.post("#{EnvHelper.env_or_error("OKTA_URL")}/oauth2/v1/userinfo", nil, {
          "Authorization": "Bearer #{access_token}"
        })
        return OpenStruct.new(
          success?: true,
          payload: JSON.parse(response.body)
        )
      rescue RestClient::BadRequest, RestClient::Unauthorized => e
        return OpenStruct.new(success?: false, error: "Token invalid")
      end
    end

    def cache_exp_in
      [(token_exp_at - Time.now), MAX_REMOTE_CACHE_TIME.from_now].min
    end

    def cache_key
      uid = decoded_token["uid"]
      md5_hash = Digest::MD5.hexdigest(access_token)
      "okta_userinfo:#{uid}_#{md5_hash}"
    end

    def token_expired?
      token_exp_at.blank? || token_exp_at.past?
    end

    def token_exp_at
      exp = decoded_token&.dig("exp")
      exp.presence && Time.at(exp)
    end

    # Decoding without local signature verification
    def decoded_token
      @decoded_token ||= JWT.decode(access_token, nil, false)[0] rescue nil
    end
  end
end
