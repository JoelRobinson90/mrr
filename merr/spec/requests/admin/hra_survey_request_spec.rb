# frozen_string_literal: true

# typed: true
require "rails_helper"
require "csv"

RSpec.describe "Admin::HraSurveys", type: :request do
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

  describe "GET index" do
    it "successfully responds with a csv file" do
      headers = {"ACCEPT" => "text/csv"}
      get admin_hra_surveys_path, headers: headers
      expect(response.content_type).to include("text/csv")

      csv = CSV.parse(response.body, headers: true)
      expect(csv).to be_empty
    end

    it "responds with a csv with the proper data" do
      hra_survey = create(:hra_survey)

      headers = {"ACCEPT" => "text/csv"}
      get admin_hra_surveys_path, headers: headers
      csv = CSV.parse(response.body, headers: true)

      expect(csv.length).to eq(1)
      expect(csv[0]["Member Id"]).to eq(hra_survey.patient.id.to_s)
    end

    it "responds with proper data for all patients" do
      Patient.all.each {|patient| create(:hra_survey, patient: patient) }

      headers = {"ACCEPT" => "text/csv"}
      get admin_hra_surveys_path, headers: headers
      csv = CSV.parse(response.body, headers: true)

      expect(csv.length).to eq(Patient.count)
    end

    it "makes a column blank if a survey question existed for one patient and not another" do
      survey1 = create(:hra_survey, survey: [{question: "test", answer: "test"}])
      survey2 = create(:hra_survey, patient: Patient.second)
      survey3 = create(:hra_survey, survey: [{question: "test", answer: "test"}])

      headers = {"ACCEPT" => "text/csv"}
      get admin_hra_surveys_path, headers: headers
      csv = CSV.parse(response.body, headers: true)

      expect(csv.length).to eq(3)
      expect(csv[0]["test"]).to eq("test")
      expect(csv[1]["test"]).to be_nil
      expect(csv[2]["test"]).to eq("test")
    end

    it "makes every column for every patient even if every survey is different" do
      survey1 = create(:hra_survey, survey: [{question: "test1", answer: "test1"}], patient: Patient.first)
      survey2 = create(:hra_survey, survey: [{question: "test2", answer: "test2"}], patient: Patient.second)
      survey3 = create(:hra_survey, survey: [{question: "test3", answer: "test3"}], patient: Patient.third)

      headers = {"ACCEPT" => "text/csv"}
      get admin_hra_surveys_path, headers: headers
      csv = CSV.parse(response.body, headers: true)

      expect(csv[0]["test1"]).to eq("test1")
      expect(csv[0]["test2"]).to be_nil
      expect(csv[0]["test3"]).to be_nil

      expect(csv[1]["test1"]).to be_nil
      expect(csv[1]["test2"]).to eq("test2")
      expect(csv[1]["test3"]).to be_nil

      expect(csv[2]["test1"]).to be_nil
      expect(csv[2]["test2"]).to be_nil
      expect(csv[2]["test3"]).to eq("test3")
    end

    it "leaves a column blank if it would show undefined" do
      survey1 = create(:hra_survey, survey:  [{question: "test1", answer: "undefined"}],
                                    patient: Patient.first)

      headers = {"ACCEPT" => "text/csv"}
      get admin_hra_surveys_path, headers: headers
      csv = CSV.parse(response.body, headers: true)

      expect(csv[0]["test1"]).to be_nil
    end
  end
end
