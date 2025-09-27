# frozen_string_literal: true

# typed: true
class DataImportController < Admin::BaseController
  require "csv"

  before_action :authenticate_medarrive_super_admin!

  def new_data_import
    @demand_partners = DemandPartner.all
    @file = KustomerCsvUpload.order("created_at").last
    @errors = @file ? KustomerCsvUploadFailure.where(kustomer_csv_upload_id: @file.id) : []

    @results = BackgroundJobResult.where(job_type: BackgroundJobResult::IMPORT_TYPES)
                                  .order(created_at: :desc)
                                  .limit(10)
    getKlass = Kustomer::GetCustomerKlasses.new
    resp = getKlass.call
    klasses = JSON.parse(resp["body"]) if resp["body"]

    host = EnvHelper.env_or_nil("HOST")
    is_prod = false

    is_prod = true if host.blank? || host.include?("prod")

    render_component "DataImporterPage", {
      isProduction:                 is_prod,
      import_results:               @results,
      queue_size:                   Delayed::Job.where(failed_at: nil).count,
      queue_errors:                 Delayed::Job.where.not(failed_at: nil).count,
      demand_partners:              @demand_partners,
      file:                         @file,
      demand_partner_custom_fields: DemandPartnerCustomField.all,
      general_fields:               %w[demand_partner medical_record_number first_name last_name middle_initial consent_to_text date_of_birth phone_number secondary_phone_number
                                       sex gender preferred_language needs_hra_survey preferred_pronouns race ethnicity primary_risk_category address_line_one address_line_two
                                       city county zipcode state latitude longitude].sort,
      klasses:                      klasses
    }
  end

  def data_import
    hasFailure = false
    redirect_to data_import_new_data_import_path, alert: "Bad file" and return unless params[:file]&.path

    unless params[:file]&.path.end_with?(".csv")
      redirect_to data_import_new_data_import_path, alert: "File extension must be .csv" and return
    end

    platforms = case params[:import_to].downcase
                when /v2_import/
                  # TODO: add more services here if we are handling custom fields
                  %w[medarrive]
                when /medarrive/
                  %w[kustomer medarrive]
                when /alayacare/
                  %w[alayacare]
                end

    run_async = params[:run_mode].downcase.include?("background")

    platforms.each do |platform|
      update_only = params[:update_mode] == "Update Only"

      uploaded_file = UploadedDataImport.create(
        user:              current_user,
        content:           File.read(params[:file].path),
        content_type:      params[:file].content_type,
        operation_type:    platform,
        demand_partner_id: params[:demand_partner_id],
        processed:         false
      )

      pending_job = BackgroundJobResult.create(
        label:    params[:file].original_filename,
        status:   "pending",
        job_type: platform
      )

      unless pending_job.persisted?
        redirect_to data_import_new_data_import_path, alert: pending_job.errors.full_messages.to_sentence and return
      end

      if run_async
        bdi = BackgroundDataImporter.new(uploaded_file.id, platform, update_only, pending_job.id)
        # Use low priority (0 is default) to avoid blocking other delayed jobs.
        bdi.delay(priority: 10).call

      else
        result = DataImporter.call(params[:file],
                                   uploaded_file.operation_type,
                                   uploaded_file.demand_partner.id,
                                   platform,
                                   update_only,
                                   pending_job.id)

        if result.success?
          # Clean up the data from the database
          # Mark as processed
          uploaded_file.update(
            content:   nil,
            processed: true
          )
        else
          hasFailure = true
        end
      end
    end

    if run_async
      redirect_to data_import_new_data_import_path, notice: "Import in progress. Reload to see results."

    elsif hasFailure
      redirect_to data_import_new_data_import_path, alert: "Something failed; check the import table"
    elsif redirect_to data_import_new_data_import_path, notice: "Import Successful"
    end
  rescue StandardError => e
    Rails.logger.debug e.message
    Rails.logger.error(e)
    Sentry.capture_exception(e)
    # To show up in local dev output
    p e.message
    redirect_to data_import_new_data_import_path, alert: "Bad shit happened"
  end

  private

  def authenticate_medarrive_super_admin!
    user_not_authorized! unless current_user&.is_super_admin?
  end
end
