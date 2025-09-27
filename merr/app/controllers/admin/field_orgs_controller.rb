# frozen_string_literal: true

# typed: true
module Admin
  class FieldOrgsController < BaseController
    load_and_authorize_resource

    def index
      render_component "FieldOrgIndexPage", field_orgs: @field_orgs
    end

    # TODO: move this to a nested users controller?
    def show
      unless validated_account_type_filter
        flash[:alert] = "Account type filter required"
        redirect_back
      end

      append_breadcrumb(@field_org.name)

      # TODO: paginate over field org accounts
      @accounts = validated_account_type_filter.constantize
                                               .includes(:user)
                                               .where(field_org: @field_org, user: {has_random_password: invited_filter})

      field_org_json = Jbuilder.encode do |json|
        json.id @field_org.id
        json.name @field_org.name

        json.accounts(@accounts) do |account|
          json.id account.id
          json.display_name account.display_name
          json.phone account.phone
          json.created_at account.created_at

          json.user do
            json.id account.user.id
            json.email account.user.email
          end
        end
      end

      render_component "FieldOrgShowPage",
                       field_org:               JSON.parse(field_org_json),
                       account_type_filter:     validated_account_type_filter,
                       invited_filter:          invited_filter,
                       readable_account_types:  readable_account_types,
                       creatable_account_types: creatable_account_types
    end

    def invite_users
      role_klass = Ability.lookup_role(account_type.camelize)
      authorize! :create, role_klass
      emails = params[:emails].split(",").map(&:strip)
      begin
        new_users = FieldUserInviter.new(emails, @field_org, role_klass).execute
        flash[:notice] = "#{new_users.count} user(s) invited."
      rescue FieldUserInviter::FieldUserInviterError => e
        flash[:alert] = e
      end
      redirect_to admin_field_org_path(@field_org)
    end

    private

    def account_type
      params[:account_type] || "FieldProvider"
    end

    def field_account_types
      [
        FieldProvider,
        FieldDispatcher,
        FieldAdmin
      ]
    end

    def readable_account_types
      field_account_types.filter {|klass| can?(:read, klass) }.map(&:to_s)
    end

    def creatable_account_types
      return [] unless can?(:invite_users, @field_org)

      field_account_types.filter {|klass| can?(:create, klass) }.map(&:to_s)
    end

    def validated_account_type_filter
      camelized_param = account_type&.camelize
      types = readable_account_types
      camelized_param&.in?(types) ? camelized_param : types.first
    end

    def invited_filter
      !!ActiveModel::Type::Boolean.new.cast(params[:invited])
    end
  end
end
