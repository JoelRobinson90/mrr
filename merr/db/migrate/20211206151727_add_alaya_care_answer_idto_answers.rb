# frozen_string_literal: true

class AddAlayaCareAnswerIdtoAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :alayacare_form_answers, :alayacare_answer_id, :string
  end
end
