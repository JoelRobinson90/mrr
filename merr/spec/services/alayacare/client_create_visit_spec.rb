# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::ClientCreateVisit do
  let(:service) { Alayacare::ClientCreateVisit }

  describe "create visit" do
    context "with empty patient" do
      it "should error" do
        expect(service.call(nil, nil, nil, nil).error).to eq("Patient Id required")
      end
    end

    context "with patient" do
      let(:service_code_id) { 7 }
      let(:patient) do
        create(:patient, medical_record_number: "l34jl4j4t")
      end

      it "should fail with error message without time" do
        response = service.call(patient, nil, nil, service_code_id)
        expect(response.body[:message]).to eq "Start time needs to be set"
      end

      it "should create visit" do
        start_time = Time.parse("18-11-2021T12:00:00Z")
        end_time = start_time + 1.hour
        response = service.call(patient, start_time, end_time, service_code_id)
        expect(response.success?).to be true
      end

      it "should create visit with field provider" do
        start_time = Time.parse("18-11-2021T12:00:00Z")
        end_time = start_time + 1.hour
        response = service.call(patient, start_time, end_time, service_code_id, field_provider_ac_external_id = "123")
        expect(response.success?).to be true
        expect(JSON.parse(response.body)["employee_id"]).to eq("123")
      end
    end
  end
end
