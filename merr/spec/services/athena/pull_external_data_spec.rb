# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athena::PullExternalData, type: :request do
  let(:service) { Athena::PullExternalData }

  let!(:local_only) { create(:cancel_code, code: "fake", athena_id: nil) }
  let!(:wrong_name) { create(:cancel_code, code: "wrong", athena_id: 25) }
  let!(:wrong_id) { create(:cancel_code, code: "Patient Hospitalized", athena_id: 999) }
  let(:actual_athena_id) { 23 }
  let!(:correct) { create(:cancel_code, code: "Patient Refused Visit", athena_id: 21) }

  let(:athena_only_name) { "PROVIDER UNAVAILABLE" }

  it "fetches external data and merges" do
    result = service.call(CancelCode, "appointmentcancelreasons")
    result_hash = result.payload
    expect(result.success?).to be true

    wrong_name.reload
    wrong_id.reload

    expect(result_hash[:matched]).to eq([correct.code])
    expect(result_hash[:updated_by_id]).to eq([wrong_name.code])
    expect(result_hash[:updated_by_name]).to eq([wrong_id.code])
    expect(result_hash[:only_in_medarrive]).to eq([local_only.code])
    expect(result_hash[:created].include?(athena_only_name)).to be true
    expect(result_hash[:skipped]).to eq([])
    expect(result_hash[:failed]).to eq([])

    expect(wrong_id.athena_id).to eq(actual_athena_id)
  end

  it "allows turning off creates and updates by id" do
    result = service.call(CancelCode, "appointmentcancelreasons",
                          allow_create: false, allow_update_by_id: false)
    result_hash = result.payload
    expect(result.success?).to be true

    wrong_name.reload
    wrong_id.reload

    expect(result_hash[:matched]).to eq([correct.code])
    expect(result_hash[:updated_by_id]).to eq([]) # suppressed
    expect(result_hash[:updated_by_name]).to eq([wrong_id.code])
    expect(result_hash[:only_in_medarrive]).to eq([local_only.code])
    expect(result_hash[:created]).to eq([]) # suppressed
    expect(result_hash[:skipped].include?(athena_only_name)).to be true
    expect(result_hash[:failed]).to eq([])

    expect(wrong_id.athena_id).to eq(actual_athena_id)
  end

  it "works with array types and custom keys" do
    result = service.call(AthenaCustomField, "customfields")
    expect(result.success?).to be true
    expect(AthenaCustomField.last.category).to eq("Patient")

    result = service.call(AthenaCustomField, "appointments/customfields", athena_wrapper_key: "appointmentcustomfields")
    expect(result.success?).to be true
    expect(AthenaCustomField.last.category).to eq("Appointment")
  end

  it "shows failures" do
    # It won't be able to create departments without the demand partners being set up.
    result = service.call(AthenaDepartment, "departments")
    expect(result.success?).to be true

    expect(result.payload[:failed][0].split(": ")[1]).to eq("Demand partner must exist")
  end
end
