# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe PatientHistory do
  let(:user) { create(:user) }
  let(:patient) { create(:patient) }
  let(:patient2) { create(:patient) }
  let!(:notes) { create_list(:admin_note, 2, creator: user, notable: patient, content: "Some note") }
  let!(:other_patient_note) { create(:admin_note, creator: user, notable: patient2, content: "Other patient note") }
  subject(:patient_history) { PatientHistory.new(patient).execute }

  context ".execute" do
    it "should generate the correct patient notes events" do
      note_events = patient_history.select {|h| h[:type] == "note" }
      expect(note_events.size).to eq 2
    end
  end
end
