# frozen_string_literal: true

module Kustomer
  class CreateRegion < ::ApplicationService
    def initialize(patient_ids, region, pending_job_id)
      @patients = Patient.where(id: patient_ids)
      @region = region.strip
      @pending_job_id = pending_job_id
    end

    def call
      errors = []

      kustomer_error_count = 0
      ma_error_count = 0

      @patients.each_with_index do |patient, i|
        sleep(60.seconds) if (i % 300).zero? && i != 0
        result = Kustomer::CreateOrUpdatePatient.call(patient,
                                                      [],
                                                      additional_params = {regionStr: @region},
                                                      update_only = true)

        kustomer_error_count += 1 if result.error

        # Is the kustomer error the update only error?
        kustomer_update_error = result.error == "Update only mode enabled, but could not find the patient"

        errors << "Kustomer error for #{patient.full_name}: #{result.error}" unless result.success?

        # We want Update Only mode enabled, as we don't want +1 patients added to Kustomer, so instead we're checking
        # and allowing MA regioning if the Kustomer error is the Update Only one
        patient.update(region: @region) if result.success? || kustomer_update_error

        ma_error_count += 1 unless patient.errors.empty?
        errors << patient.errors.full_messages.to_sentence
      end

      pending_job = BackgroundJobResult.find_by(id: @pending_job_id)

      msg = "Region '#{@region}' added to: #{@patients.length - kustomer_error_count}/#{@patients.length} Kustomer & #{@patients.length - ma_error_count}/#{@patients.length} MA profiles"

      pending_job.update(status: errors.empty? ? "succeeded" : "failed", message: msg, error_list: errors)
      nil
    end
  end
end
