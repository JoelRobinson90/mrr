# frozen_string_literal: true

class ChangeSurveyResponseToObject < ActiveRecord::Migration[6.1]
  def up
    change_column_default :surveys, :response, {}

    Survey.find_each do |survey|
      new_response = survey.response.each_with_object({}) do |response_obj, hash|
        hash[response_obj["id"]] = {
          "q" => response_obj["question"],
          "a" => response_obj["answer"]
        }
      end
      survey.update! response: new_response
    end
  end

  def down
    Survey.find_each do |survey|
      new_response = survey.response.each_with_object([]) do |(id, response_obj), array|
        array << {
          "id"       => id,
          "question" => response_obj["q"],
          "answer"   => response_obj["a"]
        }
      end
      survey.update! response: new_response
    end

    change_column_default :surveys, :response, []
  end
end
