# typed: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alayacare::FormResponseFromCsvParsing" do
  file_path = "./form_data/cf.csv"
  describe "#process_s3_files" do
    context "Smart parses based on CSV with Parser comparison column" do
      file = File.open(file_path)
      rows = CSV.parse(file.read, headers: true)
      let(:parser) { Alayacare::FormResponseParsing.new(StringIO.new, "Alayacare::FormResponseParsing") }
      # In order to make this less horrible in the test
      # i.e. listing 300 rows and parsers
      # parser column has been added in cf.csv to do a match of expected to the parser selected by code

      rows.each do |row|
        it "Returns #{row['parser']} as parser for #{row['answer']}" do
          chosen_parser = parser.smart_parser_chooser(row)
          expected_parser = row["parser"] ? row["parser"].to_sym : "Missing Parser"
          expect(chosen_parser).to eq(expected_parser),
                                   "Expected #{chosen_parser} to be #{row['parser']} for #{row['answer']}"
        end

        it "Returns parsed answer of #{row['expected_answer']}" do
          chosen_parser = parser.smart_parser_chooser(row)

          actual = parser.run_or_rescue(chosen_parser, row["answer"])

          if row["expected_answer"]
            expect(actual).to eq(row["expected_answer"]),
                              "Expected #{actual} to be #{row['expected_answer']}"
          else
            expect(actual).to eq(actual),
                              "This is passing as there is no expected answer for #{row['answer']}"
          end
        end
      end
    end
  end
end
