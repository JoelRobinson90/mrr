# typed: true
# frozen_string_literal: true

module Admin
  class HraSurveysController < ApplicationController
    load_and_authorize_resource

    def index
      respond_to do |format|
        format.csv do
          send_data HraSurveyService.create_csv(@hra_surveys),
                    type:        "text/csv; charset=iso-8859-1; header=present",
                    disposition: "attachment; filename=hra_surveys.csv"
        end
      end
    end
  end
end
