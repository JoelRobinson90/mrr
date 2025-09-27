# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routing::GetVisits, type: :request do
  let(:service) { Routing::GetVisits }

  context "with different visits in DB" do
    let!(:target_date) { Date.parse("2021-11-01") }
    let!(:start_time) { target_date + 9.hours }
    let!(:end_time) { target_date + 10.hours }

    let!(:patient) { create(:patient, medical_record_number: "3645624t56") }

    let!(:field_provider) { create(:field_provider) }
    # for test effeciency
    let!(:visit_type) { create(:visit_type) }
    let!(:program) { create(:program) }

    let!(:valid_visit) do
      create(:visit, patient: patient, start_time: start_time, end_time: end_time, field_provider: field_provider,
     visit_type: visit_type, program: program)
    end

    let!(:wrong_time_visit) do
      create(:visit, patient: patient, start_time: target_date + 10.days, end_time: target_date + 10.days,
     field_provider: field_provider, visit_type: visit_type, program: program)
    end

    let!(:different_fp_visit) do
      create(:visit, patient: patient, start_time: start_time, end_time: end_time, visit_type: visit_type,
     program: program)
    end

    let!(:different_patient_visit) do
      create(:visit, start_time: start_time, end_time: end_time, field_provider: field_provider, visit_type: visit_type,
     program: program)
    end

    let!(:canceled_visit) do
      create(:visit, patient: patient, start_time: start_time, end_time: end_time, field_provider: field_provider,
     canceled: true, cancel_code: build(:cancel_code), visit_type: visit_type, program: program)
    end

    # This requires creating a lot of database items, so all the tests are done with a single setup.
    it "fetches visits" do
      # all visits except "wrong_time_visit"
      visits = [valid_visit, different_fp_visit, different_patient_visit, canceled_visit]

      # filters by date
      result = service.call(target_date, target_date, filter_canceled = false)
      expect(result.success?).to be true
      expect(get_ids(result.payload)).to match_array(get_ids(visits))

      # filters by field_providers if specified
      result = service.call(target_date, target_date, filter_canceled = false, 
                            fp_filter_list: [field_provider.external_id, "fake_id"])
      expect(get_ids(result.payload)).to match_array(get_ids(visits.excluding(different_fp_visit)))

      # filters canceled visits by default
      result = service.call(target_date, target_date)
      expect(get_ids(result.payload)).to match_array(get_ids(visits.excluding(canceled_visit)))

      # filters other patient visits if patient specified
      result = service.call(target_date, target_date, filter_canceled = false, patient: patient)
      expect(get_ids(result.payload)).to match_array(get_ids(visits.excluding(different_patient_visit)))
    end

    def get_ids(visits)
      visits.map(&:id)
    end
  end
end
