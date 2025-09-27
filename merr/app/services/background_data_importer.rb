# frozen_string_literal: true

class BackgroundDataImporter < ApplicationService
  def initialize(upload_id, import_to, update_only, pending_job_id)
    @upload_id = upload_id
    @import_to = import_to
    @update_only = update_only
    @pending_job_id = pending_job_id
    @result = OpenStruct.new
  end

  def call
    @upload_object = UploadedDataImport.find(@upload_id)
    @result = DataImporter.call(@upload_object.file.path, @upload_object.operation_type,
                                @upload_object.demand_partner_id, @import_to, @update_only,
                                @pending_job_id)

    if @result&.success?
      @upload_object.update(
        content:   nil,
        processed: true
      )
    end

    BackgroundDataImporterMailer.import_result(@upload_object, @result).deliver_now
  rescue StandardError => e
    Rails.logger.error(e)
    Sentry.capture_exception(e)
  end
end
