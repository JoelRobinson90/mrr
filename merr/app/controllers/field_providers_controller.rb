# typed: true
# frozen_string_literal: true

class FieldProvidersController < ApplicationController
  before_action :set_field_provider, only: %i[edit update destroy]
  # TODO: Implement load_and_authorize_resource once we've finished defining access rules for
  # users beyond Medarriveadmins

  # GET /field_providers
  def index
    # TODO: include user and address if we are going to show email/address in index
    # NOTE: includes(:avatar_attachment) only loads the association to test attached?
    #       to include the actual blob use with_attached_avatar
    @field_providers = FieldProvider.with_proficiencies
                                    .includes(:avatar_attachment)
                                    .all
  end

  # GET /field_providers/1
  def show
    @field_provider = FieldProvider.with_proficiencies
                                   .with_attached_avatar
                                   .includes(:user, :address)
                                   .find(params[:id])
    @proficiency_presenter = ProficiencyPresenter.new(@field_provider)
  end

  # GET /field_providers/new
  def new
    @field_provider = FieldProvider.new
    @field_provider.build_address
    @field_provider.build_user
  end

  # GET /field_providers/1/edit
  def edit; end

  # POST /field_providers
  def create
    @field_provider = FieldProvider.new(field_provider_params)

    if @field_provider.save
      redirect_to @field_provider, notice: "Field provider was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /field_providers/1
  def update
    if @field_provider.update(field_provider_params)
      redirect_to @field_provider, notice: "Field provider was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /field_providers/1
  def destroy
    @field_provider.destroy
    redirect_to field_providers_url, notice: "Field provider was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_field_provider
    @field_provider = FieldProvider.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def field_provider_params
    user_params = %i[id email password password_confirmation]
    address_params = %i[id address_line_one address_line_two city state zipcode notes]
    params.require(:field_provider).permit(:first_name, :last_name, :phone, :date_of_birth, :field_org_id,
                                           :address_id, :provider_level, :avatar, :bio, address_attributes: address_params, user_attributes: user_params)
  end
end
