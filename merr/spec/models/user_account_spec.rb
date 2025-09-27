# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserAccount, type: :model do
  context "with auth user from omniauth callback" do
    let(:auth_hash) do
      {
        credentials: {
          expires:    true,
          expires_at: 1_635_982_864,
          token:      "tok"
        },
        extra:       {
          id_info:  {
            aud: "api://default",
            cid: "cid",
            exp: 1_635_982_864,
            iat: 1_635_979_264,
            iss: "https://medarrive-sandbox.oktapreview.com/oauth2/default",
            jti: "jti",
            scp: %w[openid email profile],
            sub: "soren@medarrive.com",
            uid: "UID",
            ver: 1
          },
          id_token: "id_tok",
          raw_info: {
            email:              "soren@medarrive.com",
            email_verified:     true,
            family_name:        "Berg",
            given_name:         "Soren",
            locale:             "en_US",
            ma_account_type:    "MedarriveOperationsAdmin",
            name:               "Soren Berg",
            phone:              "7345467319",
            preferred_username: "soren@medarrive.com",
            sub:                "UID",
            updated_at:         1_635_877_663,
            zoneinfo:           "America/Los_Angeles"
          }
        },
        info:        {
          email:      "soren@medarrive.com",
          first_name: "Soren",
          image:      nil,
          last_name:  "Berg",
          name:       "Soren Berg"
        },
        provider:    "oktaoauth",
        uid:         "UID"
      }.deep_stringify_keys
    end

    let(:auth_user) { AuthUser.from_omniauth_callback(auth_hash) }

    it "parses MedarriveAdmin" do
      account = MedarriveAdmin.from_auth_user(auth_user)

      expect(account.persisted?).to be true
      expect(account.first_name).to eq("Soren")
      expect(account.last_name).to eq("Berg")
      expect(account.phone_number).to eq("+17345467319")
    end

    context "with field hash" do
      let(:field_org) { create(:field_org) }
      let(:field_hash) do
        auth_hash["extra"]["raw_info"]["ma_field_org"] = field_org.name
        auth_hash
      end
      let(:field_auth_user) { AuthUser.from_omniauth_callback(field_hash) }

      it "parses FieldProvider" do
        account = FieldProvider.from_auth_user(field_auth_user)

        expect(account.persisted?).to be true
        expect(account.field_org.id).to eq(field_org.id)
        expect(account.first_name).to eq("Soren")
        expect(account.last_name).to eq("Berg")
        # TODO: fix once field providers have formatted phone numbers
        expect(account.phone).to eq("7345467319")
      end

      it "parses FieldDispatcher" do
        account = FieldDispatcher.from_auth_user(field_auth_user)

        expect(account.persisted?).to be true
        expect(account.field_org.id).to eq(field_org.id)
        expect(account.first_name).to eq("Soren")
        expect(account.last_name).to eq("Berg")
      end

      it "parses FieldAdmin" do
        account = FieldAdmin.from_auth_user(field_auth_user)

        expect(account.persisted?).to be true
        expect(account.field_org.id).to eq(field_org.id)
        expect(account.first_name).to eq("Soren")
        expect(account.last_name).to eq("Berg")
      end
    end

    context "with demand hash" do
      let(:demand_partner) { create(:demand_partner) }
      let(:demand_hash) do
        auth_hash["extra"]["raw_info"]["ma_demand_partner"] = demand_partner.name
        auth_hash
      end
      let(:demand_auth_user) { AuthUser.from_omniauth_callback(demand_hash) }

      it "parses DemandCoordinator" do
        account = DemandCoordinator.from_auth_user(demand_auth_user)

        expect(account.persisted?).to be true
        expect(account.demand_partner.id).to eq(demand_partner.id)
        expect(account.first_name).to eq("Soren")
        expect(account.last_name).to eq("Berg")
      end
    end
  end
end
