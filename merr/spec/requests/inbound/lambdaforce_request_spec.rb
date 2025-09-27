# frozen_string_literal: true

# Retained to ensure compatibility until LambdaForce is updated to use the new route

require "rails_helper"

RSpec.describe "Inbound Lambdaforce Controller", type: :request do
  let(:body) { "{}" }
  let(:api_key) { "lambdaforce-inbound-secret-value" }
  let(:perform_request!) do
    post "/inbound/lambdaforce", params: body, headers: {
      "Content-Type": "application/json",
      "X-API-Key":    api_key
    }
  end

  context "bad api key" do
    let(:api_key) { "asdf" }
    let(:body) do
      {
        ma_id:        "dev_Program_35",
        mode:         "update",
        payload_type: "Program",
        payload:      {
          ma_id:                "dev_Program_35",
          name:                 "Bright NC Program",
          demand_partner_ma_id: "dev_DemandPartner_45"
        }
      }.to_json
    end

    it "doesn't work" do
      perform_request!
      expect(response).to have_http_status :unauthorized
    end
  end

  describe "inbound patients" do
    let(:body) do
      {
        ma_id:        "dev_Patient_13",
        payload_type: "Patient",
        payload:      {
          ma_id:                 "dev_Patient_13",
          first_name:            "Erik",
          last_name:             "Scratch",
          address_attributes:    {
            address_line_one: "4057 MAYBERRY LN",
            city:             "CHARLOTTE",
            state:            "NC",
            zipcode:          "28212"
          },
          phone_number:          "+13054010578",
          date_of_birth:         "1999-01-01",
          contact_email:         "erik+patient@medarrive.com",
          gender:                "Agender",
          medical_record_number: "132638466551e"
        }
      }.to_json
    end

    it "does not create new patients" do
      # Just to make sure
      Patient.where(ma_id: "dev_Patient_13").delete_all
      expect { perform_request! }.not_to change(Patient, :count)

      expect(response).to have_http_status :bad_request
      missing_patient = Patient.find_by(ma_id: "dev_Patient_13")
      expect(missing_patient).not_to be
    end

    it "updates existing patients" do
      patient = create(:patient, ma_id: "dev_Patient_13", first_name: "Old name")
      expect { perform_request! }.not_to change(Patient, :count)

      patient.reload
      expect(patient.first_name).to eq "Erik"
    end
  end

  describe "inbound programs" do
    let(:body) do
      {
        ma_id:        "dev_Program_35",
        mode:         "update",
        payload_type: "Program",
        payload:      {
          ma_id:                "dev_Program_35",
          name:                 "Bright NC Program",
          active:               false,
          demand_partner_ma_id: "dev_DemandPartner_45"
        }
      }.to_json
    end

    let!(:demand_partner) { create :demand_partner, ma_id: "dev_DemandPartner_45" }

    it "creates new programs" do
      expect { perform_request! }.to change(Program, :count).by(1)

      program = Program.find_by(ma_id: "dev_Program_35")
      expect(program.name).to eq "Bright NC Program"
      expect(program.demand_partner_id).to eq demand_partner.id
      expect(program.v2?).to eq true
      expect(program.active?).to eq false
    end

    it "updates existing programs" do
      program = create(:program, ma_id: "dev_Program_35", name: "Old program name")

      expect { perform_request! }.not_to change(Program, :count)

      program.reload
      expect(program.name).to eq "Bright NC Program"
      expect(program.demand_partner_id).to eq demand_partner.id
      expect(program.v2?).to eq true
      expect(program.active?).to eq false
    end
  end

  describe "inbound visits" do
    let(:body) do
      {
        ma_id:        "dev_Visit_35",
        mode:         "update",
        payload_type: "Visit",
        payload:      {
          ma_id:     "dev_Visit_35",
          confirmed: true
        }
      }.to_json
    end

    it "updates visit confirmed flag" do
      visit = create(:visit, ma_id: "dev_Visit_35")

      expect { perform_request! }.not_to change(Visit, :count)

      visit.reload
      expect(visit.confirmed).to be true
    end
  end

  describe "inbound demand partners" do
    let(:body) do
      {
        ma_id:        "dev_DemandPartner_35",
        mode:         "create",
        payload_type: "DemandPartner",
        payload:      {
          ma_id:      "dev_DemandPartner_35",
          name:       "Blue Cross Blue Shield",
          short_name: "BCBS"
        }
      }.to_json
    end

    it "creates new demand partners" do
      expect { perform_request! }.to change(DemandPartner, :count).by(1)

      dp = DemandPartner.last
      expect(dp).to have_attributes(
        ma_id:      "dev_DemandPartner_35",
        name:       "Blue Cross Blue Shield",
        short_name: "BCBS"
      )
    end

    it "updates existing demand partners" do
      dp = create(:demand_partner, ma_id: "dev_DemandPartner_35", name: "old name", short_name: "old short name")
      expect { perform_request! }.not_to change(DemandPartner, :count)

      dp.reload
      expect(dp).to have_attributes(
        ma_id:      "dev_DemandPartner_35",
        name:       "Blue Cross Blue Shield",
        short_name: "BCBS"
      )
    end
  end
end
