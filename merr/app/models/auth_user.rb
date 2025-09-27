# frozen_string_literal: true

AUTH_USER_FIELDS = %i[
  provider
  email
  uid
  first_name
  last_name
  phone_number
  account_type
  field_org_name
  demand_partner_name
].freeze

AuthUser = Struct.new(*AUTH_USER_FIELDS, keyword_init: true) do
  def self.from_omniauth_callback(auth)
    from_userinfo(auth.dig("extra", "raw_info"))
  end

  def self.from_userinfo(info)
    new(
      provider:            "oktaoauth",
      # Downcase email to match Devise behavior
      email:               info["email"].downcase,
      uid:                 info["sub"],
      first_name:          info["given_name"],
      last_name:           info["family_name"],
      phone_number:        info["phone"],
      account_type:        info["ma_account_type"],
      field_org_name:      info["ma_field_org"],
      demand_partner_name: info["ma_demand_partner"]
    )
  end
end
