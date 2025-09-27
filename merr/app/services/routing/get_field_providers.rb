# frozen_string_literal: true

require "haversine"

module Routing
  class GetFieldProviders < ::ApplicationService
    include Helpers

    def initialize
      @alayacare_api = Authentication::Api.new(Authentication::AlayacareBroker)
      @wiw_api = Authentication::Api.new(Authentication::WhenIWorkBroker)
    end

    def call
      @shifts = []

      get_fps_from_when_i_work
    end

    def get_fps_from_when_i_work
      result = @wiw_api.get("users")
      return result unless result.success?

      body = JSON.parse(result.body)

      active_fps = []
      body["users"].each do |u|
        if u["locations"].length.positive? && u["employee_code"].length.positive?
          active_fps.push u
        end
      end
      save_field_providers(active_fps)
    end

    def save_field_providers(active_fps)
      fps_synced = []
      fps_skipped = []
      fps_failed = []
      active_fps.each do |fp|

        field_provider = FieldProvider.includes(:address, :user).find_or_initialize_by(external_id: fp["employee_code"])
        field_provider.field_org = FieldOrg.find_or_initialize_by(name: "dummy_org")

        field_provider.first_name = fp["first_name"]
        field_provider.last_name = fp["last_name"]
        field_provider.skip_push_to_external = true
        fp_ac = fetch_fp_from_ac(fp["employee_code"])

        if fp["email"].present?
          if field_provider.user
            @user = field_provider.user
            # Protects against failure if an FP in AC has the email of a different FP in MA
            # Should only be a consideration in local/test/stage
            if (User.find_by(email: fp["email"]).blank?) 
              @user.email = fp["email"]
            end
          else
            @user = User.find_or_initialize_by(email: fp["email"])
          end
          @user.skip_push_to_external = true
          @user.assign_random_password
          field_provider.user = @user
        end

        if fp_ac["demographics"] && fp_ac["demographics"]["address"].present? && fp_ac["demographics"]["state"].present? && fp_ac["demographics"]["zip"].present? && fp_ac["demographics"]["city"].present?
          if field_provider.address
            field_provider.address.address_line_one= fp_ac["demographics"]["address"]
            field_provider.address.address_line_two= fp_ac["demographics"]["address_suite"]
            field_provider.address.city=             fp_ac["demographics"]["city"]
            field_provider.address.state=            fp_ac["demographics"]["state"]
            field_provider.address.zipcode=          fp_ac["demographics"]["zip"]
            field_provider.address.latitude=         fp_ac["demographics"]["location"]["lat"]
            field_provider.address.longitude=        fp_ac["demographics"]["location"]["lon"]
          else 
            address = Address.new
            address.address_line_one= fp_ac["demographics"]["address"]
            address.address_line_two= fp_ac["demographics"]["address_suite"]
            address.city=             fp_ac["demographics"]["city"]
            address.state=            fp_ac["demographics"]["state"]
            address.zipcode=          fp_ac["demographics"]["zip"]
            address.latitude=         fp_ac["demographics"]["location"]["lat"]
            address.longitude=        fp_ac["demographics"]["location"]["lon"]
            field_provider.address = address
          end
        end

        if !field_provider.address
          fps_skipped.push("#{fp["first_name"]} #{fp["last_name"]}")
        end

        if field_provider.save
          fps_synced.push("#{fp["first_name"]} #{fp["last_name"]}")
        else
          fps_failed.push("#{fp["first_name"]} #{fp["last_name"]}, Error: #{field_provider.errors.full_messages.to_sentence}")
        end

      end
      return OpenStruct.new(success?: true, message: "Active FPs (Fps with an employee id and schedule in WIW) synced: #{fps_synced} | Active FPs skipped because they lack an address in AC: #{fps_skipped} } | Active FPs that failed to save: #{fps_failed}")

    end

    def fetch_fp_from_ac(employee_code)
      resp = @alayacare_api.get("employees/employees/by_id/#{employee_code}")
      JSON.parse(resp.body)
    end
  end
end
