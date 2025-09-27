require "rails_helper"

RSpec.describe CancelTermedPatientVisits do
  let(:patient) { create :patient }

  let!(:not_eligible_cancel_code) { create :cancel_code, code: "Not Eligible", athena_id: 1 }
  let!(:existing_cancel_code) { create :cancel_code, code: "Scheduler Error", athena_id: 2 }

  let!(:past_visit) { create :visit, patient: patient, start_time: 1.hour.ago }
  let!(:future_cancelled_visit) { create :visit, patient: patient, start_time: 1.day.from_now, canceled: true, cancel_code_id: existing_cancel_code.id }
  let!(:future_visit) { create :visit, patient: patient, start_time: 3.days.from_now }

  around(:each) do |example|
    begin
      old_val = ENV["NOT_ELIGIBLE_CANCEL_CODE_ID"]
      ENV["NOT_ELIGIBLE_CANCEL_CODE_ID"] = not_eligible_cancel_code.id.to_s
      example.run
    ensure
      ENV["NOT_ELIGIBLE_CANCEL_CODE_ID"] = old_val
    end
  end

  it "cancels future non-cancelled visits" do
    CancelTermedPatientVisits.call(patient)

    past_visit.reload
    expect(past_visit.canceled).to be_falsy
    expect(past_visit.cancel_code_id).to be_nil

    future_cancelled_visit.reload
    expect(future_cancelled_visit.canceled).to be_truthy
    expect(future_cancelled_visit.cancel_code_id).to eq existing_cancel_code.id

    future_visit.reload
    expect(future_visit.canceled).to be_truthy
    expect(future_visit.cancel_code_id).to eq not_eligible_cancel_code.id
  end
end
