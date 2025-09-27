# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::GetShifts, type: :request do
  let(:service) { Routing::GetShifts }

  let!(:dallas_fp) do
    create(:field_provider, first_name: "Dallas", last_name: "FP",
                           external_id: "FieldProvider_NKVMBzw5FQuHzhc5", role: "field_provider",
                           address: nil)
  end

  let!(:houston_fp) do
    create(:field_provider, first_name: "Houston TX", last_name: "FP",
                             external_id: "45540", role: "field_provider",
                             address: nil)
  end

  context "with start and end date" do
    let(:target_date) { Date.parse("2021-11-01") }

    # This will be used to find the FP "group"
    let!(:existing_visit) do
      patient = create(:patient, demand_partner: create(:demand_partner, name: "Molina"))
      create(:visit, field_provider: houston_fp, patient: patient)
    end

    it "fetches shifts and adds fp locations" do
      result = service.call(target_date, target_date)

      expect(result.success?).to be true

      # NOTE: test based on cached VCR response.
      expected = [{end_time:      Time.zone.parse("2021-11-01 23:00:00 +0000"),
                   fp_id:         "FieldProvider_NKVMBzw5FQuHzhc5",
                   fp_name:       "Dallas FP",
                   provider_role: "field_provider",
                   groups:        [],
                   location:      "32.78385,-96.79827",
                   location_name: "SANDBOX Molina- Houston",
                   start_time:    Time.zone.parse("2021-11-01 13:00:00 +0000"),
                   providers: []},
                  {end_time:      Time.zone.parse("2021-11-01 23:00:00 +0000"),
                   fp_id:         "45540",
                   fp_name:       "Houston TX FP",
                   provider_role: "field_provider",
                   groups:        ["Molina"],
                   location:      "29.77985,-95.56049",
                   location_name: "SANDBOX Molina- Houston",
                   start_time:    Time.zone.parse("2021-11-01 13:00:00 +0000"),
                   providers: []}]

      expect(result.payload).to eq(expected)
    end

    it "fetches all users" do
      result = service.call(target_date, target_date, include_users: true)

      expect(result.success?).to be true
      expect(result.payload.length > 5).to be true
    end

    context "with anchor location" do
      # about 10 miles away from one of the field providers working that day
      let(:anchor_location) do
        "32.786764,-96.626408"
      end
      it "finds shift within radius" do
        result = service.call(target_date, target_date, anchor_location: anchor_location, max_distance: 50)

        expect(result.success?).to be true
        expect(result.payload.length).to eq(1)
      end

      it "ignores shift outside of radius" do
        result = service.call(target_date, target_date, anchor_location: anchor_location, max_distance: 5)

        expect(result.success?).to be true
        expect(result.payload.length).to eq(0)
      end

      it "doesn't filter locations of virtual providers" do
        resource_requirements = [
          {
            provider_role: "field_provider",
            in_home:       false
          }
        ]
        result = service.call(target_date, target_date, anchor_location: anchor_location, max_distance: 5,
resource_requirements: resource_requirements)

        expect(result.success?).to be true
        expect(result.payload.length).to eq(2)
      end
    end

    context "filtering by provider" do
      it "filters out providers with undesired IDs" do
        result = service.call(target_date, target_date, assigned_fp_ids: ["FAKE_ID"])

        expect(result.success?).to be true
        expect(result.payload.length).to eq(0)
      end

      it "leaves in provider with the desired ID" do
        result = service.call(target_date, target_date, assigned_fp_ids: ["45540"])

        expect(result.success?).to be true
        expect(result.payload.length).to eq(1)
      end

      it "works correctly with empty fp ids" do
        result = service.call(target_date, target_date, assigned_fp_ids: [])

        expect(result.success?).to be true
        expect(result.payload.length).to eq(0)
      end
    end
  end

  context "can get location from WiW from site_id" do
    let(:target_date) { Date.parse("2022-08-14") }
    it "gets the location" do
      # WARNING: This isn't getting a location anymore and
      # isn't testing what it appears to test.
      result = service.call(target_date, target_date)

      expect(result.success?).to be true

      # NOTE: test based on cached VCR response, to re-generate you need to add a real key to test.rb
      expected = {
        start_time:    Time.zone.parse("2022-08-14 13:00:00.000000000 +0000"),
        end_time:      Time.zone.parse("2022-08-14 21:00:00.000000000 +000"),
        fp_id:         "FieldProvider_NKVMBzw5FQuHzhc5",
        fp_name:       "Dallas FP",
        provider_role: "field_provider",
        groups:        [],
        location:      "36.057426,-79.825508",
        location_name: "SANDBOX Molina- Houston",
        providers: []
      }

      expect(result.payload).to eq([expected])
    end
  end

  context "can get location from WiW from location_id" do
    let(:target_date) { Date.parse("2022-08-13") }
    it "gets the location" do
      result = service.call(target_date, target_date)

      expect(result.success?).to be true

      # NOTE: test based on cached VCR response, to re-generate you need to add a real key to test.rb
      expected = {
        start_time:    Time.zone.parse("2022-08-13 13:00:00.000000000 +0000"),
        end_time:      Time.zone.parse("2022-08-13 21:00:00.000000000 +0000"),
        fp_id:         "FieldProvider_NKVMBzw5FQuHzhc5",
        fp_name:       "Dallas FP",
        groups:        [],
        location:      "32.78385,-96.79827",
        provider_role: "field_provider",
        location_name: "SANDBOX Molina- Houston",
        providers: []
      }

      expect(result.payload).to eq([expected])
    end
  end
end
