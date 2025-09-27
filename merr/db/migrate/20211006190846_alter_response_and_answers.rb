# frozen_string_literal: true

class AlterResponseAndAnswers < ActiveRecord::Migration[6.1]
  def change
    rename_column :alayacare_form_answers, :response, :reply
    rename_column :alayacare_form_answers, :alayacare_form_response_id, :response_id
  end
end
