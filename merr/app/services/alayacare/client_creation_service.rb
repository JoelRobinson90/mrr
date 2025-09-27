# typed: true
# frozen_string_literal: true

module Alayacare
  class ClientCreationService < ::ApplicationService
    attr_accessor :patient, :endpoint

    def initialize(patient)
      @api = Authentication::Api.new(Authentication::AlayacareBroker)
      @endpoint = "patients/clients"
      @patient = patient

      @address = @patient.address
    end

    def call
      @api.post(endpoint, body)
    end

    def language_to_alayacare_language
      @patient.preferred_language
    end

    def gender_to_alayacare_gender
      @patient.gender
    end

    def address_block
      if @address
        {
          address:       @address.address_line_one,
          address_suite: @address.address_line_two,
          city:          @address.city,
          state:         @address.state,
          zip:           @address.zipcode
        }
      else
        {}
      end
    end

    def body
      base = {
        demographics: {
          birthday:       @patient.date_of_birth,
          first_name:     @patient.first_name,
          gender:         @gender_to_alayacare_gender,
          last_name:      @patient.last_name,
          phone_main:     @patient.phone_number,
          phone_other:    @patient.secondary_phone_number,
          phone_personal: @patient.phone_number
        },
        external_id:  @patient.id.to_s,
        branch_id:    2001,
        profile_id:   12_345,
        language:     language_to_alayacare_language,
        timezone:     @address ? @address.timezone : "America/Toronto"
      }

      base[:demographics] = base[:demographics].merge(address_block)
      base
    end
  end
end
