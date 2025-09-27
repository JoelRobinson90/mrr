# typed: true
# frozen_string_literal: true

require "set"
require "csv"
class HraSurveyService
  def self.create_csv(hra_surveys)
    # generate csv header row by looping through each survey and adding each question to an array
    generated_header_row = Set[] # make this a set https://ruby-doc.org/stdlib- 2.7.2/libdoc/set/rdoc/Set.html
    hra_surveys.find_each do |hra_survey|
      hra_survey.survey.each do |question_answer|
        unless ["Member Id", "Member Name"].include?(question_answer["question"])
          generated_header_row << question_answer["question"]
        end
      end
    end

    columns = ["Member Id", "Member Name"] + generated_header_row.to_a

    # create a csv file
    CSV.generate do |csv|
      # Header row
      csv << columns
      hra_surveys.find_each {|hra_survey| csv << csv_row(hra_survey, columns) }
    end
    # return csv file
  end

  def self.csv_row(hra_survey, columns)
    hash = {
      "Member Id"   => hra_survey.patient.id,
      "Member Name" => hra_survey.patient.display_name
    }
    hra_survey.survey.each do |question_answer|
      unless question_answer["answer"].blank? || question_answer["answer"] == "undefined"
        hash[question_answer["question"]] =
          question_answer["answer"]
      end
    end
    columns.map {|column| hash[column] }
  end
end
