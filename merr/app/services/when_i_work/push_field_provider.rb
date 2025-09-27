# frozen_string_literal: true

module WhenIWork
  class PushFieldProvider < ::ApplicationService
    def initialize(mode, field_provider)
      @wiw_api = Authentication::Api.new(Authentication::WhenIWorkBroker)

      @mode = mode
      @fp = field_provider
    end

    def call
      # Since we can't update by "employee id", we have to fetch all users from WiW to get
      # the internal id of the field provider we are updating if they exist.
      users_query = @wiw_api.get("users")
      unless users_query.success?
        return OpenStruct.new(success?: false,
                              error:    "Failed to sync to WiW: #{users_query.body}")
      end
      query_result = JSON.parse(users_query.body)
      existing_wiw_user = query_result["users"].detect {|e| e["employee_code"] == @fp.external_id }

      # For this service, we don't care about mode but simply insert or update based on whether the
      # user exists already or not.
      if existing_wiw_user.blank?
        @wiw_api.post("users", body)
      else
        @wiw_api.put("users/#{existing_wiw_user['id']}", body)
      end
    end

    def body
      {
        email:         @fp.email,
        first_name:    @fp.first_name,
        last_name:     @fp.last_name,
        phone_number:  @fp.phone,
        employee_code: @fp.external_id
      }
    end
  end
end
