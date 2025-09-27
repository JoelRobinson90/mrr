# frozen_string_literal: true

module Types
  module Params
    class CreatePatientParams < GraphQL::Schema::InputObject
      graphql_name "CreatePatientParams"

      argument :first_name, String
      argument :last_name, String
      argument :demand_partner_id, ID
      argument :medical_record_number, String
      argument :date_of_birth, String
      argument :phone_number, String
      argument :consent_to_text, Boolean, required: false
      argument :sex, String
      argument :preferred_language, String, required: false
      argument :address_attributes, Types::Params::CreateAddressParams
      argument :user_attributes, Types::Params::CreateUserParams
    end
  end
end
