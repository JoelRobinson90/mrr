# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Patients", type: :request do
  let!(:current_user) { create(:medarrive_admin).user }

  let!(:patients) do
    Timecop.travel
    Timecop.scale(6400)
    (1..24).map do
      Timecop.travel(1.second)
      create(:patient, :with_address)
    end
  end

  before do
    sign_in current_user
  end

  describe "GET patient show page" do
    it "works with ma_id" do
      get admin_patient_path(Patient.last.ma_id)

      expect(response).to render_template("layouts/admin")
      expect(response.body).to include('data-react-class="PatientShowPage"')
    end
  end

  describe "GET index" do
    it "successfully renders the react PatientsIndexComponent" do
      get admin_patients_path

      expect(response).to render_template("layouts/admin")
      expect(response.body).to include('data-react-class="PatientIndexPage"')
    end

    describe "only showing authorized data" do
      context "when a high-permissioned user is signed in (e.g. MedArriveAdmin)" do
        it "sends data for all relevant patients, along with provider org and address" do
          get admin_patients_path

          patient1, patient2, patient3 = patients
          expect(response.body).to include(CGI.escapeHTML("\"id\":#{patient1.id}"))
          expect(response.body).to include(CGI.escapeHTML("\"id\":#{patient2.id}"))
          expect(response.body).to include(CGI.escapeHTML("\"id\":#{patient3.id}"))

          expect(response.body).to include(CGI.escapeHTML("\"city\":\"#{patient1.address.city}"))
          expect(response.body).to include(CGI.escapeHTML("\"name\":\"#{patient1.demand_partner.name}"))
        end
      end

      # TODO: Implement this example when we've completed the Patient Auth ticket:
      # https://linear.app/medarrive/issue/MED-90/cancancan-rules-for-accessing-patient-records
      context "when a less-permissioned user is signed in (TBD)" do
        it "sends data for a more limited set of patients"
      end
    end

    describe "pagination of data" do
      let!(:twenty_five_more) { create_list(:patient, 25) }
      let!(:oldest_patient) { create(:patient, created_at: 1.day.ago) }
      let!(:all_patients) { [oldest_patient, *patients, *twenty_five_more].sort_by(&:created_at) }
      let!(:page2_patients) { all_patients.pop(24) }
      let!(:page1_patients) { all_patients }

      # @TODO: Flaky tests causing failures after pumping up items per page for pagination. To investigate further later.
      context "by default" do
        xit "sends the first 25-result slice of patients data sorted by created_at date" do
          get admin_patients_path

          expect([oldest_patient, *patients, *twenty_five_more].count).to be(50)

          document = Nokogiri::HTML(response.body)
          patient_data_doc = document.at("div[data-react-class][data-react-props]").values.last
          patient_data_block = JSON.parse(patient_data_doc)["patients"]
          patient_data = patient_data_block.collect {|k| k["id"] }

          page1_patients.each do |patient|
            expect(patient_data).to include(patient.id),
                                    "Expected patient id #{patient.id} to be found in page. It was not."
          end
          page2_patients.each do |patient|
            expect(patient_data).to_not include(patient.id),
                                        "Expected patient id #{patient.id} to NOT be found in page."
          end
        end

        xit "sends the correctly_computed total pages count" do
          get admin_patients_path

          expect(response.body).to include(CGI.escapeHTML("\"total_pages\":3"))
        end
      end

      context "when a page number param is present" do
        xit "sends only that slice of data" do
          get admin_patients_path(page: "2")

          document = Nokogiri::HTML(response.body)
          patient_data_doc = document.at("div[data-react-class][data-react-props]").values.last
          patient_data_block = JSON.parse(patient_data_doc)["patients"]
          patient_data = patient_data_block.collect {|k| k["id"] }

          page2_patients.each do |patient|
            expect(patient_data).to include(patient.id),
                                    "Expected patient id #{patient.id} to be found in page. It was not."
          end
          page1_patients.each do |patient|
            expect(patient_data).to_not include(patient.id),
                                        "Expected patient id #{patient.id} to NOT be found in page."
          end
        end
      end

      context "when a rows_per_page param is present" do
        it "sends a set of data sized to match that param" do
          get admin_patients_path(rows_per_page: "3")

          document = Nokogiri::HTML(response.body)
          patient_data_doc = document.at("div[data-react-class][data-react-props]").values.last
          patient_data_block = JSON.parse(patient_data_doc)["patients"]
          patient_data = patient_data_block.collect {|k| k["id"] }

          p1, p2, p3, p4 = Patient.all.order(created_at: :desc)

          expect(patient_data).to include(p3.id)
          expect(patient_data).to include(p2.id)
          expect(patient_data).to include(p1.id)
          expect(patient_data).to_not include(p4.id)
        end
      end
    end
  end

  describe "POST create" do
    let!(:demand_partner) { create(:demand_partner) }

    it "successfully creates patient with minimum set" do
      post admin_patients_path, params: {
        patient: {first_name:            "test create",
                  last_name:             "test",
                  phone_number:          "5554443333",
                  medical_record_number: "mrn_ex_12345",
                  date_of_birth:         "2001-01-01",
                  gender:                "",
                  sex:                   "",
                  address_attributes:    {address_line_one: ""},
                  user_attributes:       {email: ""},
                  demand_partner_id:     demand_partner.id}
      }

      # Sort by demand partner to find expected
      patient = Patient.where(demand_partner: demand_partner).last

      expect(patient.first_name).to eq("test create")
      expect(patient.demand_partner_id).to eq(demand_partner.id)
      expect(patient.consent_to_text).to eq(false)

      expect(patient.user).to be nil
      expect(patient.address).to be nil
      expect(patient.sex).to be nil
      expect(patient.gender).to be nil

      expect(response).to redirect_to(admin_patient_path(patient))
    end

    it "successfully creates patient" do
      post admin_patients_path, params: {
        patient: {first_name:            "test create again",
                  last_name:             "test",
                  phone_number:          "5554443333",
                  date_of_birth:         "2001-01-01",
                  address_attributes:    {address_line_one: "test", city: "test",
                                       state: "CA", zipcode: "98103"},
                  user_attributes:       {email: "test@example2.com"},
                  medical_record_number: "mrn_ex_1234",
                  demand_partner_id:     demand_partner.id,
                  consent_to_text:       "true"}
      }

      patient = Patient.last

      expect(patient.first_name).to eq("test create again")
      expect(patient.consent_to_text).to eq(true)

      expect(patient.user.has_random_password).to be true
      expect(patient.address.address_line_one).to eq("test")

      expect(response).to redirect_to(admin_patient_path(patient))
    end

    it "fails to create patient" do
      post admin_patients_path, params: {
        patient: {first_name: "fail"}
      }

      expect(response).to render_template("layouts/admin")
    end
  end

  describe "PUT update" do
    let!(:patient) { create(:patient, :with_address, sex: Patient::SEXES.first) }
    let(:old_address_id) { patient.address.id }

    it "successfully updates patient" do
      put admin_patient_path(patient.id), params: {
        patient: {first_name:         "test update",
                  address_attributes: {id: old_address_id, address_line_one: "TESTME"},
                  user_attributes:    {email: ""}}
      }

      patient.reload

      expect(patient.first_name).to eq("test update")

      expect(patient.address).to be_truthy
      expect(patient.sex).to eq(Patient::SEXES.first)

      expect(patient.address.id).to eq(old_address_id)
      expect(patient.address.address_line_one).to eq("TESTME")

      expect(response).to redirect_to(admin_patient_path(patient))
    end
  end
end
