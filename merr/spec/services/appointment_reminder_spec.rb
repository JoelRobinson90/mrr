# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppointmentReminder do
  let(:alayacare_broker) { Authentication::AlayacareBroker }

  context "on specific day" do
    before do
      Timecop.freeze(Time.zone.local(2022, 5, 16, 12))
    end

    after do
      Timecop.return
    end

    it "generates url and fetches all visits in reminder range" do
      url = AppointmentReminder.new.schedule_url

      expect(url).to eq("scheduler/visits?start_at=2022-05-18T04%3A00%3A00Z&end_at=2022-05-19T03%3A59%3A59Z")
    end

    it "formats time" do
      expected = "Thursday, Nov 18 2021. The provider will arrive between 9:30AM and 10:30AM"
      expect(AppointmentReminder.new.formatted_time("2021-11-18T015:03:00Z", "America/New_York", nil, nil)).to eq(expected)
    end

    it "uses arrival window properties for format time if available" do
      expected = "Thursday, Nov 18 2021. The provider will arrive between 8:03AM and 12:03PM"
      expect(AppointmentReminder.new.formatted_time("2021-11-18T015:03:00Z", "America/New_York", Time.zone.parse("2021-11-18 13:03:11 UTC"), Time.zone.parse("2021-11-18 17:03:11 UTC"))).to eq(expected)
    end

    it "fetches appointments" do
      partner = create :demand_partner, name: "Centene - Health Net"
      program = create :program, name: "Centene - CalViva Health - Vaccine", demand_partner: partner
      patient = create :patient, medical_record_number: "erik-calviva", demand_partner: partner, programs: [program]

      result = AppointmentReminder.new.get_reminders

      # VCR result from test appointment
      # NOTE: also fetches non-bright appt but filters it out
      # TODO: update VCR to include visits from centene, molina, and another group that doesn't use SMS
      # TODO: add patient from a different demand partner
      expect(result.payload).to eq([
                                     {
                                       patient_mrn:          "erik-calviva",
                                       start_time:           "Wednesday, May 18 2022. The provider will arrive between 9:15AM and 10:15AM",
                                       partner_display_name: "CalViva Health",
                                       kustomer_program:     "Centene - Health Net (Fresno/Sac, CA) - Vaccine",
                                       conversation_name:    "Appointment Reminder SMS: Wednesday, May 18 2022. The provider will arrive between 9:15AM and 10:15AM"
                                     }
                                   ])
    end

    it "uses arrival windows from MA visit for appointments fetched from AC" do
      partner = create :demand_partner, name: "Centene - Health Net"
      program = create :program, name: "Centene - CalViva Health - Vaccine", demand_partner: partner
      patient = create :patient, medical_record_number: "erik-calviva", demand_partner: partner, programs: [program]
      visit = create :visit, patient: patient, external_id: "Visit_Fake_Pete_Made_This_Up", start_time: Time.zone.parse("2022-05-18 16:42:00 UTC"), arrival_window_start: Time.zone.parse("2022-05-18 14:42:00 UTC"), arrival_window_end: Time.zone.parse("2022-05-18 18:42:00 UTC")

      result = AppointmentReminder.new.get_reminders

      expect(result.payload).to eq([
                                     {
                                       patient_mrn:          "erik-calviva",
                                       start_time:           "Wednesday, May 18 2022. The provider will arrive between 7:42AM and 11:42AM",
                                       partner_display_name: "CalViva Health",
                                       kustomer_program:     "Centene - Health Net (Fresno/Sac, CA) - Vaccine",
                                       conversation_name:    "Appointment Reminder SMS: Wednesday, May 18 2022. The provider will arrive between 7:42AM and 11:42AM"
                                     }
                                   ])
    end

    it "skips unconfigured programs" do
      partner = create :demand_partner, name: "Centene - Health Net"
      program = create :program, name: "Centene - CalViva Health - Monkey Pox Vaccine", demand_partner: partner
      patient = create :patient, medical_record_number: "erik-calviva", demand_partner: partner, programs: [program]

      result = AppointmentReminder.new.get_reminders

      expect(result.payload).to eq([])
    end
  end

  context "with reminders" do
    let(:reminders) do
      [
        {patient_mrn:          "3645624t56",
         start_time:           "Thursday Nov 18 2021 at  7:00AM",
         partner_display_name: "Health Net",
         kustomer_program:     "Centene - Health Net (LA, CA) - Vaccine",
         conversation_name:    "Conversation"}
      ]
    end

    it "uploads to Kustomer" do
      result = AppointmentReminder.new.create_notification_conversations(reminders, "trigger tag")

      expect(result.success?).to be true
    end
  end
end
