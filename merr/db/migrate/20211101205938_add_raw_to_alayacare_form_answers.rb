# frozen_string_literal: true

class AddRawToAlayacareFormAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :alayacare_form_answers, :raw, :text
  end
end
