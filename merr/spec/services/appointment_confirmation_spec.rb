# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppointmentConfirmation do
  let(:address) { build(:address, :los_angeles) }
  let(:patient) { build(:patient, address: address, external_id: "1234") }
  let(:visit) { build(:visit, patient: patient, start_time: Time.zone.parse("2022-07-11 20:42:11 UTC")) }
  let(:visit_with_window) { build(:visit, patient: patient, start_time: Time.zone.parse("2022-07-11 20:42:11 UTC"), arrival_window_start: Time.zone.parse("2022-07-11 18:42:11 UTC"), arrival_window_end: Time.zone.parse("2022-07-11 22:42:11 UTC")) }
  let(:api) { instance_double(Authentication::Api) }

  before do
    allow(Authentication::Api).to receive(:new).and_return(api)
    allow(api).to receive(:get).and_return(OpenStruct.new({success?: true, body: "{\"data\": {\"id\": \"abc123\"}}"}))
    allow(api).to receive(:post).and_return(OpenStruct.new({success?: true, body: "{\"data\": {\"id\": \"jkl456\"}}"}))
    allow(api).to receive(:put).and_return(OpenStruct.new({success?: true}))
  end

  it "fails for missing partners" do
    expect(api).to_not receive(:post)
    visit.program.demand_partner.name = "Not a real partner"
    result = AppointmentConfirmation.new(visit).call
    expect(result.success?).to be false
    expect(result.error).to match(/unknown program/)
  end

  it "fails for missing programs" do
    expect(api).to_not receive(:post)
    visit.program.demand_partner.name = "Centene - Health Net"
    visit.program.name = "Centene - monkey pox vaccinations"
    result = AppointmentConfirmation.new(visit).call
    expect(result.success?).to be false
    expect(result.error).to match(/unknown program/)
  end

  it "skips disabled programs" do
    expect(api).to_not receive(:post)
    visit.program.demand_partner.name = "Molina"
    visit.program.name = "Molina 2021 Houston TX ED Utilization Reduction"
    result = AppointmentConfirmation.new(visit).call
    expect(result.success?).to be true
  end

  it "works for known program" do
    expect(api).to receive(:post).once
    expect(api).to receive(:put).once
    visit.program.demand_partner.name = "Centene - Health Net"
    visit.program.name = "Centene - CalViva Health - Vaccine"
    result = AppointmentConfirmation.new(visit).call
    expect(result.success?).to be true
  end

  it "sends visit start in local time" do
    result = AppointmentConfirmation.new(visit).formatted_time
    expect(result).to eq("Monday, Jul 11 2022. The provider will arrive between 1:15PM and 2:15PM")
  end

  it "uses arrival window properties if available" do
    result = AppointmentConfirmation.new(visit_with_window).formatted_time
    expect(result).to eq("Monday, Jul 11 2022. The provider will arrive between 11:42AM and 3:42PM")
  end
end
