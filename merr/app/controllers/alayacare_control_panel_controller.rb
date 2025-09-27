# frozen_string_literal: true

# typed: true

class AlayacareControlPanelController < ApplicationController
  before_action :authenticate_medarrive_super_admin!

  def index; end

  def sync_demand_partner_ids
    result = Alayacare::DemandPartnerIdSyncService.call
    flash.now.notice = "Updated AlayaCare IDs for: #{result[:matched_groups]} ----- Found in AlayaCare but not MedArrive: #{result[:unmatched_groups]}"
    render :index
  end

  def sync_cancel_code_ids
    result = Alayacare::PullExternalData.call(CancelCode, "scheduler/cancelcodes", :code)
    if result.success?
      @results = result.payload
      flash.now.notice = "Synced cancel codes"
    else
      flash.now.alert = result.error
    end
    render :index
  end

  def sync_service_ids
    result = Alayacare::PullExternalData.call(Service, "scheduler/services/forms", :name)
    if result.success?
      @results = result.payload
      flash.now.notice = "Synced services"
    else
      flash.now.alert = result.error
    end
    render :index
  end

  def dedup_mrns
    pending_job = BackgroundJobResult.create(
      label:    "mrn_deduper",
      status:   "pending",
      job_type: "mrn_deduper"
    )

    mrn_cleaner = PatientMrnDeduper.new(pending_job.id)
    mrn_cleaner.delay.call
    redirect_to alayacare_control_panel_index_path, notice: "Deduping MRNs..."
  end

  def sync_visit_types
    result = Alayacare::PullExternalData.call(VisitType, "scheduler/service_codes", :name)
    if result.success?
      @results = result.payload
      flash.now.notice = "Synced visit types"
    else
      flash.now.alert = result.error
    end

    render :index
  end

  def backfill_field_providers
    resp = Routing::GetFieldProviders.call
    flash.now.notice = resp.message
    render :index
  end

  def clear_caches
    Rails.cache.delete("ac_service_codes")
    Rails.cache.delete("ac_cancel_codes")
    Rails.cache.delete("ac_demand_partner_groups")
    Rails.cache.delete_matched("ac_field_provider_name_*")
    Rails.cache.delete_matched("ac_field_provider_loc_*")
    Rails.cache.delete_matched("ac_patient_loc_internal_id_*")

    redirect_to alayacare_control_panel_index_path, notice: "Cleared caches"
  end

  def backfill_visits
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    dry_run = params[:run_mode] != "Create"

    pending_job = BackgroundJobResult.create(
      label:    "Backfill visits #{params[:run_mode]} mode dates #{start_date} to #{end_date}",
      status:   "pending",
      job_type: "backfill_alayacare_data"
    )

    unless pending_job.persisted?
      redirect_to alayacare_control_panel_index_path, alert: pending_job.errors.full_messages.to_sentence and return
    end

    backfill_process = Alayacare::BackfillVisits.new(pending_job.id, dry_run: dry_run,
                                                     start_date: start_date, end_date: end_date)

    if params[:async_mode].include? "background"
      backfill_process.delay.call
      redirect_to alayacare_control_panel_index_path, notice: "Backfill job scheduled"
    else
      result = backfill_process.call

      if result.success?
        redirect_to alayacare_control_panel_index_path, notice: result.message
      else
        redirect_to alayacare_control_panel_index_path, alert: result.error.truncate(350)
      end
    end
  end

  private

  def authenticate_medarrive_super_admin!
    user_not_authorized! unless current_user&.is_super_admin?
  end
end
