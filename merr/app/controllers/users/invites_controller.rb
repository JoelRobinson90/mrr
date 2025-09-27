# typed: true
# frozen_string_literal: true

module Users
  class InvitesController < ApplicationController
    # TODO: Implement load_and_authorize_resource once we've defined access rules for
    # guest/invited users

    layout "application"

    def show
      @token = params[:token]
      redirect_to root_path, alert: "Invite token missing" and return if @token.blank?

      @user = User.with_reset_password_token(@token)

      unless @user&.reset_password_period_valid?
        # TODO: render invite not found
        redirect_to root_path, alert: "Invite invalid" and return
      end

      output = Jbuilder.encode do |json|
        json.user do
          json.id @user.id
          json.account_type @user.account_type
          json.account do
            account = @user.account
            json.first_name account.first_name
            json.last_name account.last_name

            if (field_org = account.try(:field_org))
              json.field_org do
                json.id field_org.id
                json.name field_org.name
              end
            end
          end
        end

        json.token @token
      end

      render_component "AcceptInvitePage", JSON.parse(output)
    end

    def update
      @user = User.reset_password_by_token(user_params.slice(:password, :password_confirmation, :reset_password_token))
      unless @user.valid?
        flash[:alert] = [@user.errors.full_messages, @user.password_suggestions].flatten.join("; ")
        return redirect_to users_invites_path(token: params[:reset_password_token])
      end

      @user.account.update! user_params.fetch(:account_attributes)

      # TODO: redirect to proper path depending on user type
      redirect_to root_path, notice: "Welcome!"
    end

    private

    def user_params
      params.require(:user).permit(:password, :password_confirmation, :reset_password_token,
                                   account_attributes: %i[first_name last_name])
    end
  end
end
