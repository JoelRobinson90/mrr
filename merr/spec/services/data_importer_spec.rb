# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataImporter do
  let(:type) { "scan_patient_import" }
  let!(:demand_partner) { create(:demand_partner) }
  let(:demand_partner_id) { demand_partner.id }
  let(:update_only) { false }
  let(:client_create_or_update) { instance_double(Alayacare::ClientCreateOrUpdateService) }
  let(:program) { create(:program, demand_partner: demand_partner) }

  before do
    allow(Alayacare::ClientCreateOrUpdateService).to receive(:new).and_return(client_create_or_update)
    allow(client_create_or_update).to receive(:fetch_groups).and_return([demand_partner])
  end

  describe "helper functions" do
    it "Parses multiple date types" do
      expect(CSV).to receive(:read).and_return([])
      mock = double("csv_file")
      importer = DataImporter.new(mock, type, demand_partner_id, "MedArrive", update_only)
      target_date = Date.parse("1930-04-04")

      expect(importer.parsed_date("1930-04-04")).to eq(target_date)
      expect(importer.parsed_date("04/04/1930")).to eq(target_date)
      expect(importer.parsed_date("4/4/1930")).to eq(target_date)
      expect(importer.parsed_date("4/4/30")).to eq(target_date)
      expect(importer.parsed_date("4/4/1930")).to eq(target_date)
      expect(importer.parsed_date("4/4")).to be_nil
    end

    it "Normalizes languages" do
      expect(CSV).to receive(:read).and_return([])
      mock = double("csv_file")
      importer = DataImporter.new(mock, type, demand_partner_id, "MedArrive", update_only)

      expect(importer.parsed_preferred_language("English")).to eq("English")
      expect(importer.parsed_preferred_language("Espanol")).to eq("Spanish")
      expect(importer.parsed_preferred_language("")).to be_nil
    end
  end

  describe "is called", :vcr do
    context "without rows" do
      it "returns error" do
        expect(CSV).to receive(:read).and_return([])
        mock = double("csv_file")
        result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", nil)
        expect(result.success?).to eq false
        expect(result.error).to eq "No data received"
      end
    end

    context "without type" do
      it "returns error" do
        expect(CSV).to receive(:read).and_return([{test: "test"}])
        mock = double("csv_file")
        result = DataImporter.call(mock, "", demand_partner_id, "MedArrive", update_only)
        expect(result.success?).to eq false
        expect(result.error).to eq "Type not found"
      end
    end

    context "with generic medarrive format" do
      let(:type) { "medarrive" }
      let!(:test_MRN) { "1123581321" }
      let!(:test_last_name) { "Smith" }
      let!(:user) { create(:user) }
      let(:service1) { create(:service) }
      let(:service2) { create(:service) }
      let(:rows) do
        [
          {
            demand_partner:         demand_partner.name,
            first_name:             "Bob",
            last_name:              test_last_name,
            date_of_birth:          "4/20/1985",
            phone_number:           "7345467319",
            secondary_phone_number: "5555555555",
            medical_record_number:  test_MRN,
            sex:                    "Male",
            gender:                 "Man",
            preferred_language:     "English",
            address_line_one:       "1812 E Republican St",
            address_line_two:       "Apt 9",
            city:                   "Seattle",
            county:                 "King",
            state:                  "WA",
            zipcode:                "98112",
            program:                program.name,
            service_requests:       "#{service1.name}|#{service2.name}",
            service_area:           "service area 1",
            geo_cohort:             "geo cohort 1",
            other_field:            "Should go in notes",
            datalake_id:            "datalake"
          }.stringify_keys
        ]
      end

      it "Won't upload duplicate patients" do
        rows << {medical_record_number: test_MRN, program: program.name}.stringify_keys

        expect do
          expect(CSV).to receive(:read).and_return(rows)
          mock = double("csv_file")
          result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

          expect(result.success?).to be false
          expect(result.error).to eq("Duplicate MRNs: #{test_MRN}")
        end.to change { Patient.count }.by(0)
      end

      it "stops before creating if any validation fail" do
        rows[0]["preferred_language"] = "FAKELANG"
        expect do
          expect(CSV).to receive(:read).and_return(rows)
          mock = double("csv_file")
          result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

          expect(result.success?).to be false
          expect(result.error).to eq("Import error on row 0: Preferred language 'Fakelang' is not a recognized language")
        end.to change { Patient.count }.by(0)
      end

      context "in update only mode" do
        let(:update_only) { true }

        it "stops before creating" do
          expect do
            expect(CSV).to receive(:read).and_return(rows)
            mock = double("csv_file")
            result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

            expect(result.success?).to be false
            expect(result.error).to include(test_MRN)
          end.to change { Patient.count }.by(0)
        end
      end

      it "imports new patients", :run_delayed_jobs do
        expect {
          expect(CSV).to receive(:read).and_return(rows)
          mock = double("csv_file")
          result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

          expect(result.success?).to be true

          patient = Patient.last
          expect(patient.status).to eq("Created")

          expect(patient.geo_cohort.name).to eq("geo cohort 1")
          expect(patient.service_area.name).to eq("service area 1")
          expect(patient.datalake_id).to eq("datalake")
        }.to change { Patient.count }.by(1)
         .and change { Address.count }.by(1)
         .and change { AdminNote.count }.by(1)
         .and change { BackgroundJobResult.count }.by(1)
         .and change { ServiceRequest.count }.by(2)
         .and change { ServiceArea.count }.by(1)
         .and change { GeoCohort.count }.by(1)
         .and change { PatientGeo.count }.by(1)
      end

      context "with existing patient" do
        let!(:existing_patient) do
          create(:patient,
                 :with_address,
                 demand_partner:        demand_partner,
                 medical_record_number: test_MRN,
                 last_name:             test_last_name,
                 preferred_language:    "Spanish",
                 sex:                   "Female")
        end
        # create Admin note as if this data has been imported before
        let!(:admin_note) do
          create(:admin_note,
                 creator_id: nil,
                 notable:    existing_patient,
                 content:    "Demand partner: #{demand_partner}\nOther field: Should go in notes")
        end

        let!(:exisiting_service_request) { create(:service_request, patient: existing_patient, program: program, service: service1) }

        let(:pending_job) do
          create(:background_job_result, job_type: "medarrive", status: "pending",
                                   label: "TEST", message: nil, error_list: nil)
        end

        let(:service_area) { create(:service_area, name: "service area 1") }
        let(:geo_cohort) { create(:geo_cohort, name: "geo cohort 1", service_area: service_area) }
        let!(:patient_geo) { create(:patient_geo, patient: existing_patient, geo_cohort: geo_cohort,
                                                  service_area: service_area, program: program) }

        context "with database ids" do
          let(:new_medical_record_number) { "3j3l4jllgefl" }
          it "updates patient by postgres id", :run_delayed_jobs do
            expect do
              expect(existing_patient.medical_record_number != new_medical_record_number).to be true
              rows[0]["medical_record_number"] = new_medical_record_number
              rows[0]["postgres_id"] = existing_patient.id

              expect(CSV).to receive(:read).and_return(rows)
              mock = double("csv_file")
              result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

              existing_patient.reload

              expect(existing_patient.medical_record_number).to eq(new_medical_record_number)

            end.to change { Patient.count }.by(0)
          end

          it "won't update if postgres_id not found", :run_delayed_jobs do
            expect do
              rows[0]["postgres_id"] = "99999"
              update_only = true

              expect(CSV).to receive(:read).and_return(rows)
              mock = double("csv_file")
              result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

              expect(result.success?).to be false
              expect(result.error).to eq("Update only mode enabled, but could not find patients with postgres_ids: [\"99999\"]")

            end.to change { Patient.count }.by(0)
          end
        end

        it "updates patients by medial record number", :run_delayed_jobs do
          expect {
            rows[0]["medical_record_number"] = test_MRN
            expect(CSV).to receive(:read).and_return(rows)
            mock = double("csv_file")
            result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only, pending_job.id)

            expect(result.success?).to be true

            patient = Patient.find_by(medical_record_number: test_MRN, demand_partner: demand_partner)

            # patient and address have been updated, but the note was left untouched
            expect(patient.preferred_language).to eq("English")
            expect(patient.sex).to eq("Male")
            expect(patient.address.address_line_one).to eq("1812 E Republican St")

            # patient already had the first service request, should now have both (one merged one new).
            expect(patient.service_requests.pluck(:service_id)).to eq([service1.id, service2.id])

            expect(patient.geo_cohort.name).to eq("geo cohort 1")
            expect(patient.service_area.name).to eq("service area 1")
          }.to change { Patient.count }.by(0)
           .and change { Address.count }.by(0)
           .and change { AdminNote.count }.by(1)
           .and change { ServiceRequest.count }.by(1)
           .and change { ServiceArea.count }.by(0)
           .and change { GeoCohort.count }.by(0)
           .and change { PatientGeo.count }.by(0) # finds the existing one

          rows[0]["other_field"] = "New content"

          # test update only mode happy path
          update_only = true

          # Check adding of note if content changed.
          # Also test re-using BackgroundJobResult id.
          # Also test changing name of service area and geo when already existing
          expect {
            rows[0]["service_area"] = "new service area"
            rows[0]["geo_cohort"] = "new geo cohort"
            rows[0]["medical_record_number"] = test_MRN
            expect(CSV).to receive(:read).and_return(rows)
            mock = double("csv_file")

            result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only, pending_job.id)

            expect(result.success?).to be true

            patient = Patient.find_by(medical_record_number: test_MRN, demand_partner: demand_partner)

            expect(patient.admin_notes.last.content).to eq("Demand partner: #{demand_partner}\nProgram: #{program.name}\nOther field: New content")

            pending_job.reload

            expect(pending_job.status).to eq("succeeded")
            expect(pending_job.message).to eq("1/1 rows imported")
            expect(pending_job.error_list).to be_nil

            expect(patient.service_area.name).to eq("new service area")
            expect(patient.geo_cohort.name).to eq("new geo cohort")
          }.to change { Patient.count }.by(0)
           .and change { Address.count }.by(0)
           .and change { AdminNote.count }.by(1)
           .and change { BackgroundJobResult.count }.by(0)
           .and change { ServiceRequest.count }.by(0)
           .and change { ServiceArea.count }.by(1)
           .and change { GeoCohort.count }.by(1)
           .and change { PatientGeo.count }.by(0) # updates the existing one
        end

        context "with missing fields" do
          it "updates patient without overriding not-present fields", :run_delayed_jobs do
            expect do
              # Creating patient to have existing fields not to update
              expect(CSV).to receive(:read).and_return(rows)
              mock = double("csv_file")
              result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

              patient = Patient.find_by(medical_record_number: test_MRN, demand_partner: demand_partner)

              # Sex updated, but preferred language left untouched.
              expect(patient.preferred_language).to eq("English")
              expect(patient.sex).to eq("Male")

              rows[0]["sex"] = "Female"
              rows[0]["preferred_language"] = nil
              expect(CSV).to receive(:read).and_return(rows)
              mock = double("csv_file")
              result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

              expect(result.success?).to be true

              patient = Patient.find_by(medical_record_number: test_MRN, demand_partner: demand_partner)

              # Sex updated, but preferred language left untouched.
              expect(patient.preferred_language).to eq("English")
              expect(patient.sex).to eq("Female")
            end.to change { Patient.count }.by(0)
          end
        end

        context "with fields marked for removal" do
          it "updates patient with a nil value if csv value is ***remove***", :run_delayed_jobs do
            expect do
              # Creating patient to have existing fields not to update
              expect(CSV).to receive(:read).and_return(rows)
              mock = double("csv_file")
              result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

              patient = Patient.find_by(medical_record_number: test_MRN, demand_partner: demand_partner)

              # Verify initial state pre-changes
              expect(patient.preferred_language).to eq("English")
              expect(patient.sex).to eq("Male")

              rows[0]["sex"] = "Female"
              rows[0]["preferred_language"] = "***REMOVE***"
              expect(CSV).to receive(:read).and_return(rows)
              mock = double("csv_file")
              result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

              expect(result.success?).to be true

              patient = Patient.find_by(medical_record_number: test_MRN, demand_partner: demand_partner)

              # Sex updated, and preferred language removed.
              expect(patient.preferred_language).to be_nil
              expect(patient.sex).to eq("Female")
            end.to change { Patient.count }.by(0)
          end
        end

        context "with insurance info" do
          let(:insurance_hash) do
            {
              insurance_id_number: "insurance id 1",
              insurance_sequence_number: 2,
              policy_holder_first_name: "Ins",
              policy_holder_last_name: "Test",
              policy_holder_sex: "Female",
              insurance_package_id: 2,
              relationship_to_insured_id: 2,
            }.stringify_keys
          end

          it "creates new insurance policy" do
            expect do
              # rows = rows.map {|row| row.merge(insurance_hash)}
              expect(CSV).to receive(:read).and_return([rows[0].merge(insurance_hash)])
              mock = double("csv_file")
              result = DataImporter.call(mock, type, demand_partner_id, "MedArrive", update_only)

              patient = Patient.find_by(medical_record_number: test_MRN, demand_partner: demand_partner)

              insurance = patient.insurance_policies.last

              expect(insurance).not_to be nil

              expect(insurance.program_id).to eq(program.id)

              insurance_hash.keys.each do |key|
                expect(insurance[key]).to eq(insurance_hash[key])
              end

            end.to change { Patient.count }.by(0).and change { InsurancePolicy.count }.by(1)
          end
        end
      end
    end
  end
end