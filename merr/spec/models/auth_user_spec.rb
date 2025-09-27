# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthUser do
  describe ".from_omniauth_callback" do
    let(:auth) do
      json = '{"provider":"oktaoauth","uid":"00u1zm263iZ2byJVf1d7","info":{"name":"Erik Lyngved","email":"Erik@medarrive.com","first_name":"Erik","last_name":"Lyngved","image":null},"credentials":{"token":"token1234","expires_at":1675728426,"expires":true},"extra":{"raw_info":{"sub":"00u1zm263iZ2byJVf1d7","name":"Erik Lyngved","locale":"en_US","email":"erik@medarrive.com","preferred_username":"erik@medarrive.com","given_name":"Erik","family_name":"Lyngved","phone":"+13054010579","zoneinfo":"America/Los_Angeles","updated_at":1638322844,"email_verified":true,"ma_account_type":"MedarriveAdmin","ma_demand_partner":"N/A","ma_field_org":"N/A"},"id_token":"token1234","id_info":{"ver":1,"jti":"AT.0ORpms9EHGhjaf9MGRTT6P8v-oBQnV_XWeQwIkO5OZg","iss":"https://medarrive-sandbox.oktapreview.com/oauth2/default","aud":"api://default","iat":1675724826,"exp":1675728426,"cid":"0oa1qtkgkiz8m0tl61d7","uid":"00u1zm263iZ2byJVf1d7","scp":["email","phone","openid","profile"],"auth_time":1675723460,"sub":"erik@medarrive.com"}}}'
      JSON.parse(json)
    end

    it "returns an auth user object" do
      expect(described_class.from_omniauth_callback(auth).to_h).to eq({
                                                                        provider:            "oktaoauth",
                                                                        email:               "erik@medarrive.com",
                                                                        uid:                 "00u1zm263iZ2byJVf1d7",
                                                                        first_name:          "Erik",
                                                                        last_name:           "Lyngved",
                                                                        phone_number:        "+13054010579",
                                                                        account_type:        "MedarriveAdmin",
                                                                        field_org_name:      "N/A",
                                                                        demand_partner_name: "N/A"
                                                                      })
    end
  end

  describe ".from_userinfo" do
    let(:userinfo) do
      {
        "sub"                => "00u8rl7ar2YbRoehv696",
        "name"               => "Erik Lyngved",
        "locale"             => "en_US",
        "email"              => "erik@medarrive.com",
        "preferred_username" => "erik@medarrive.com",
        "given_name"         => "Erik",
        "family_name"        => "Lyngved",
        "phone"              => "+13054010579",
        "zoneinfo"           => "America/Los_Angeles",
        "updated_at"         => 1_675_473_473,
        "email_verified"     => true,
        "ma_account_type"    => "MedarriveAdmin",
        "ma_demand_partner"  => "N/A",
        "ma_field_org"       => "N/A"
      }
    end

    it "returns an auth user object" do
      expect(described_class.from_userinfo(userinfo).to_h).to eq({
                                                                   provider:            "oktaoauth",
                                                                   email:               "erik@medarrive.com",
                                                                   uid:                 "00u8rl7ar2YbRoehv696",
                                                                   first_name:          "Erik",
                                                                   last_name:           "Lyngved",
                                                                   phone_number:        "+13054010579",
                                                                   account_type:        "MedarriveAdmin",
                                                                   field_org_name:      "N/A",
                                                                   demand_partner_name: "N/A"
                                                                 })
    end
  end
end
