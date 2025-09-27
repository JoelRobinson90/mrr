# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alayacare::FormResponseParsing do
  describe "#single_response_with_other" do
    let(:parser) { Alayacare::FormResponseParsing.new(StringIO.new, "Alayacare::FormResponseParsing") }
    it "pulls Yes from Raw" do
      raw = '{"option": {"name": "Yes", "value": "Yes"}}'
      expect(parser.single_response_with_other(raw)).to eq("Yes")
    end

    it "returns raw on failure" do
      raw = "Invalid Content"
      expect(parser.single_response_with_other(raw)).to eq(raw)
    end
  end

  describe "#smart_parser_chooser" do
    let(:parser) { Alayacare::FormResponseParsing.new(StringIO.new, "Alayacare::FormResponseParsing") }

    it "returns medications" do
      def answer
        <<-ROW
        values: [
          {field_key: "medication_name", field_value: "Protonix"},
          {field_key:   "medication_type",
           field_value: {option: {name: "prescriptions", value: "prescriptions"}}},
          {field_key: "status", field_value: {option: {name: "active", value: "active"}}},
          {field_key:   "information_source",
           field_value: {option: {name: "physician_rx", value: "physician_rx"}}},
          {field_key: "ordering_physician", field_value: null},
          {field_key: "high_alert", field_value: null},
          {field_key: "comments", field_value: null},
          {field_key: "discrepancy", field_value: null},
          {field_key: "discrepancy_status", field_value: null},
          {field_key: "discrepancy_note", field_value: null},
          {field_key: "healthcare_professional_notified", field_value: null},
          {field_key: "dose", field_value: "20"},
          {field_key: "dose_type", field_value: {option: {name: "mg", value: "mg"}}},
          {field_key: "route", field_value: {option: {name: "po_oral", value: "po_oral"}}},
          {field_key:   "administered_by",
           field_value: {option: {name: "not_assisted", value: "not_assisted"}}},
          {field_key: "delivery_mode", field_value: null},
          {field_key: "timing_unknown_start_date", field_value: true},
          {field_key: "timing_unknown_end_date", field_value: true},
          {field_key: "timing_start_date", field_value: null},
          {field_key: "timing_end_date", field_value: null},
          {field_key:   "time_instruction",
           field_value: {options: [{name: "qam_once_a_day_am", value: "qam_once_a_day_am"}]}},
          field_key:   "administration_times",
          field_value: null
        ]
      ]
        ROW
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:medications)
    end

    it "returns immunizations_administered" do
      def answer
        <<-ROW
       [
         values: [
           {field_key: "type", field_value: {other: "COVID-19"}},
           {field_key: "date", field_value: "2021-08-16"},
           field_key:   "booster_date",
           field_value: null
         ]
       ]

        ROW
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:immunizations_administered)
    end

    it "respiratory_rate" do
      def answer
        <<-ROW
      [
        values: [
          {field_key: "unit", field_value: {option: {name: "BPM", value: "BPM"}}},
          field_key:   "respiratory_rate",
          field_value: "18"
        ]
      ]
        ROW
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:respiratory_rate)
    end

    it "temperature_and_unit" do
      def answer
        raw = <<-ROW
       {
         "values": [
           {"field_key": "route", "field_value": {"option": {"name": "temporal", "value": "temporal"}}},
           {"field_key": "temperature", "field_value": 97.8},
           {"field_key": "unit",
           "field_value": {"option": {"name": "f", "value": "f"}}
           }
         ]
       }
        ROW

        raw.gsub("\n", "")
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:temperature_and_unit)
    end

    it "height" do
      def answer
        <<-ROW
       [
         "values": [
           {"field_key": "height", "field_value": "167"},
           "field_key": "unit",
           "field_value": {"option": {"name": "cm", "value": "cm"}}
         ]
       ]

        ROW
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:height)
    end

    it "weight_with_unit" do
      def answer
        <<-ROW
      [
      "values": [
        {"field_key": "unit", "field_value": {"option": {"name": "lb", "value": "lb"}}},
        "field_key": "weight",
        "field_value": "144"
      ]
      ]
        ROW
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:weight_with_unit)
    end

    it "bmi" do
      def answer
        <<-ROW
       [
         "values": [
           {"field_key": "body_mass", "field_value": 23.2},
           {"field_key": "unit", "field_value": {"option": {"name": "kg/m2", "value": "kg/m2"}}},
           "field_key": "comments",
           "field_value": "FSBG 131"
         ]
       ]
        ROW
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:bmi)
    end

    it "allergies" do
      def answer
        <<-ROW
       [
         values: [
           {field_key: "name", field_value: "Risperidone"},
           {field_key: "treatment", field_value: "Felt strange "},
           {field_key: "type", field_value: {option: {name: "Medication", value: "Medication"}}},
           {field_key: "severity", field_value: {option: {name: "Mild", value: "Mild"}}},
           field_key:   "date",
           field_value: null
         ]
       ]
        ROW
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:allergies)
    end

    it "past_medical_diagnoses" do
      def answer
        <<-ROW
       [
         values: [
           {field_key:   "diagnosis",
            field_value: "J440=Chronic obstructive pulmonary disease with (acute) lower respiratory infection"},
           {field_key: "treatment", field_value: null},
           {field_key: "start_date", field_value: "2020-08-04"},
           {field_key: "end_date", field_value: null},
           field_key:   "notes",
           field_value: null
         ]
       ]
        ROW
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:past_medical_diagnoses)
    end

    it "any_of_the_following" do
      def answer
        '{"options": [{"name": "Nausea", "value": "Nausea"}, {"name": "Headache", "value": "Headache"}, {"name": "Difficulty thinking clearly,", "value": "Difficulty thinking clearly,"}]}'
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:any_of_the_following)
    end

    it "single_response_with_other" do
      def answer
        '{"option": {"name": "Yes", "value": "Yes"}}'
      end

      row = CSV::Row.new(%w[field_tag question_name answer], ["smart", "Med Smart", answer])
      sp = parser.smart_parser_chooser(row)
      expect(sp).to be(:single_response_with_other)
    end
  end
end
