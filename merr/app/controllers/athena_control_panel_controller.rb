# frozen_string_literal: true

# typed: true

class AthenaControlPanelController < ApplicationController
  before_action :authenticate_medarrive_super_admin!

  def index; end

  def sync_department_ids
    result = Athena::PullExternalData.call(AthenaDepartment, "departments")
    process_response(result, "department")
  end

  def sync_cancel_code_ids
    result = Athena::PullExternalData.call(CancelCode, "appointmentcancelreasons")
    process_response(result, "cancel code")
  end

  def sync_service_ids
    result = Athena::PullExternalData.call(Service, "configuration/encounterreasons")
    process_response(result, "service")
  end

  def sync_visit_type_ids
    result = Athena::PullExternalData.call(VisitType, "appointmenttypes")
    process_response(result, "visit type")
  end

  def sync_custom_field_ids
    result = Athena::PullExternalData.call(AthenaCustomField, "customfields")
    result_2 = Athena::PullExternalData.call(AthenaCustomField, "appointments/customfields",
                                             athena_wrapper_key: "appointmentcustomfields")

    if result.success? && result_2.success?
      Rails.cache.delete("athena_custom_fields")

      result.payload = result.payload.map do |key, value|
        [key, value.concat(result_2.payload[key] || [])]
      end
      process_response(result, "custom fields")
    else
      flash.now.alert("#{result.error} #{result_2.error}")
      render :index
    end
  end

  def initialize_regression_fixtures
    result = RegressionInitializer.call()

    process_response(result, "Initialized regression fixtures", label_override: true)
  end

  private

  def process_response(result, label, label_override: false)
    @results = result.payload
    
    if result.success?
      notice = label_override ? label : "Synced #{label}s"
      flash.now.notice = notice
    else
      flash.now.alert = result.error
    end

    render :index
  end

  def authenticate_medarrive_super_admin!
    user_not_authorized! unless current_user&.is_super_admin?
  end
end
