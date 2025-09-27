# typed: true
# frozen_string_literal: true

module Alayacare
  class ProcessClinicalForm100a < S3::FetchFile
    def process_s3_files
      notifier = CronJob::Notification.new
      existing_processed_files = Alayacare::ProcessedFile.where(processed: true).select(:filename).collect(&:filename)
      new_files = list_files - existing_processed_files

      processed_file_status = new_files.collect do |filename|
        # Do not process the failures of CSV importer as part of the Form answers
        unless filename.match?(/ClinicalForms/i)
          Rails.logger.warn("#{filename} is being skipped due to not being a Clinical Form Dump")
          next
        end

        processed_file = Alayacare::ProcessedFile.new(
          filename:      filename,
          form_template: "Alayacare::FormTemplate::Form100a",
          processed_on:  DateTime.now
        )

        file = fetch(@bucket, filename)

        # Set the processor
        csv_parser = Alayacare::FormResponseParsing.new(file, processed_file.form_template)

        all_answers = csv_parser.form_responses

        # Save em all

        processed_file.update(
          processed: true,
          rows:      csv_parser.rows_parsed,
          responses: all_answers
        )

        slack_notification(processed_file_status, false, filename)
        processed_file.save
      rescue StandardError => e
        Rails.logger.error("Processing of #{filename} failed. #{e.message}")
        processed_file.update(
          errored:        true,
          error_messages: e.message
        )

        message = "#{self.class} threw #{error.full_message} during processing of #{filename} on #{Rails.env}"
        notifier.slack(message)

        next
      end

      message = success_message(processed_file_status)
      notifier.slack(message)

      processed_file_status.all?
    end

    def success_message(processed_file_status)
      if processed_file_status.all?
        <<~ERRORMESSAGE
          All #{processed_file_status.count} were processed successfully on #{Rails.env} using
          #{self.class}
        ERRORMESSAGE
      else
        <<~ERRORMESSAGE
          #{processed_file_status.count(true)} were processed successfully.
          #{processed_file_status.count(false)} failed on #{Rails.env} while running
          #{self.class}.
        ERRORMESSAGE
      end
    end
  end
end
