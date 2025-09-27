# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::PullExternalData, type: :request do
  let(:service) { Alayacare::PullExternalData }

  let!(:local_only) { create(:cancel_code, code: "fake", alayacare_id: 99) }
  let!(:wrong_name) { create(:cancel_code, code: "wrong", alayacare_id: 3) }
  let!(:wrong_id) { create(:cancel_code, code: "Patient No Show", alayacare_id: 999) }
  let!(:correct) { create(:cancel_code, code: "Patient Requested Reschedule", alayacare_id: 5) }

  it "fetches external data and merges" do
    result = service.call(CancelCode, "scheduler/cancelcodes", :code)
    result_hash = result.payload
    expect(result.success?).to be true

    wrong_name.reload
    wrong_id.reload

    expect(result_hash[:matched]).to eq([correct.code])
    expect(result_hash[:updated_by_id]).to eq([wrong_name.code])
    expect(result_hash[:updated_by_name]).to eq([wrong_id.code])
    expect(result_hash[:only_in_medarrive]).to eq([local_only.code])
    expect(result_hash[:created].include?("Patient Reported COVID Exposure")).to be true

    expect(wrong_id.alayacare_id).to eq(4)
  end

  it "filters data by latest id and active" do
    result = service.call(Service, "scheduler/services/forms", :name)
    result_hash = result.payload
    expect(result.success?).to be true

    # form with multiple versions gets the largest id
    expect(Service.where(name: "Bright Health Standard Visit (v071822)").count).to eq(1)
    expect(Service.find_by(name: "Bright Health Standard Visit (v071822)").alayacare_id).to eq("293")

    # inactive form not synced
    expect(Service.find_by(name: "000 COVID-19").present?).to be false
  end
end
