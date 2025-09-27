# typed: true
# frozen_string_literal: true

module Alayacare
  class FieldProviderCreateOrUpdateService < ApiClient
    def initialize(mode, field_provider)
      super()

      @mode = mode
      @fp = field_provider
      @address = @fp.address
    end

    def call
      if @mode == :update
        @api.put("employees/employees/by_id/#{@fp.external_id}", body)
      else
        @api.post("employees/employees", body)
      end
    end

    def body
      request_body = {
        demographics: {
          first_name: @fp.first_name,
          last_name:  @fp.last_name,
          email:      @fp.user&.email
        },
        # We have to create the FP before the user account, so we can't
        # use email for this initially, but when the user is created it
        # will come back here and update.
        username:     @fp.user&.email || @fp.external_id
      }

      request_body[:demographics] = request_body[:demographics].merge(address_block)

      if @mode == :create
        available_roles = @api.get("employees/roles")
        fp_role = JSON.parse(available_roles.body)["items"].find do |role|
          role["description"].start_with?("Field Provider") # The role is pluralized in UAT
        end

        request_body[:external_id] = @fp.external_id
        request_body[:roles] = [fp_role]
        request_body[:status] = "active"
      end

      request_body
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
  end
end
