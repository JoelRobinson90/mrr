# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Appointments", type: :request do
  let!(:current_user) { create(:medarrive_admin).user }

  let!(:patients) do
    Timecop.travel
    Timecop.scale(6400)
    (1..3).map do
      Timecop.travel(1.second)
      create(:appointment)
    end
  end

  before do
    sign_in current_user
  end

  describe "GET index" do
    it "successfully renders the react AppointmentIndexComponent" do
      get admin_appointments_path

      expect(response).to render_template("layouts/admin")
      expect(response.body).to include('data-react-class="AppointmentIndexPage"')
    end
  end

  describe "GET new" do
    let(:patient) { create(:patient, address: nil) }
    it "successfully renders the react AppointmentEditPage" do
      get new_admin_appointment_path, params: {patient_id: patient.id}

      expect(response).to render_template("layouts/admin")
      expect(response.body).to include('data-react-class="AppointmentEditPage"')
    end
  end

  describe "POST create" do
    let!(:patient) { create(:patient) }

    it "successfully creates appointment" do
      post admin_appointments_path, params: {
        appointment: {patient_id:         patient.id,
                      status:             "Created",
                      address_attributes: {address_line_one: "test", city: "test",
                                           state: "CA", zipcode: "98103"}}
      }

      appointment = Appointment.last

      expect(appointment.patient).to eq(patient)
      expect(appointment.status).to eq("Created")
      expect(appointment.address).to be_truthy

      expect(response).to redirect_to(admin_appointment_path(appointment))
    end

    it "fails to create appointment with insufficient data" do
      post admin_appointments_path, params: {
        appointment: {status: "Pending Acceptance"}
      }

      expect(response).to redirect_to(admin_appointments_path)
    end
  end

  describe "PUT update" do
    let!(:appointment) { create(:appointment) }

    it "successfully updates appointment" do
      put admin_appointment_path(appointment.id), params: {
        appointment: {status: "Pending Acceptance"}
      }

      appointment.reload

      expect(appointment.status).to eq("Pending Acceptance")

      expect(response).to redirect_to(admin_appointment_path(appointment))
    end

    it "successfully update appointment status" do
      put admin_appointment_path(appointment.id), params: {
        appointment: {status: "Pending Acceptance"}
      }

      appointment.reload

      expect(appointment.status).to eq("Pending Acceptance")

      expect(response).to redirect_to(admin_appointment_path(appointment))
    end
  end

end
