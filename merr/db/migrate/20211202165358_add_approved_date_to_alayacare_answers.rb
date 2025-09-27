# frozen_string_literal: true

class AddApprovedDateToAlayacareAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :alayacare_form_answers, :approved_date, :string
  end
end
