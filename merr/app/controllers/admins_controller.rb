# typed: true
# frozen_string_literal: true

class AdminsController < ApplicationController
  before_action :set_admin, only: %i[show edit update destroy]
  before_action :check_type, only: %i[new create update]
  # TODO: Implement load_and_authorize_resource once we've finished defining access rules for
  # users beyond Medarriveadmins

  # GET /admins
  def index
    @admins = FieldAdmin.all +
              FieldDispatcher.all +
              MedarriveAdmin.all +
              MedarriveCustomerSupport.all +
              MedarriveClinicalOperations.all
  end

  # GET /admins/1
  def show; end

  # GET /admins/new
  def new
    @admin = get_admin_class.new
    @admin.build_user
  end

  # GET /admins/1/edit
  def edit; end

  # POST /admins
  def create
    @admin = get_admin_class.new(admin_params)

    if @admin.save
      redirect_to admin_url(@admin, type: @admin.type), notice: "Admin was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /admins/1
  def update
    if @admin.update(admin_params)
      redirect_to admin_url(@admin, type: @admin.type), notice: "Admin was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /admins/1
  def destroy
    @admin.destroy
    redirect_to admins_url, notice: "Admin was successfully destroyed."
  end

  private

  def get_admin_class
    Ability::ROLES[params[:role].camelize]
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_admin
    @admin = get_admin_class.find(params[:id])
  end

  def check_type
    redirect_to request.referer, alert: "Admin type not specified" if params[:type].blank?
  end

  # Only allow a list of trusted parameters through.
  def admin_params
    user_params = %i[id email password password_confirmation]
    params.require(params[:type].to_sym).permit(:first_name, :last_name, :field_org_id, user_attributes: user_params)
  end
end
