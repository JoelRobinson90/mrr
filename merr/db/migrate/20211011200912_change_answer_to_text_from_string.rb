class ChangeAnswerToTextFromString < ActiveRecord::Migration[6.1]
  def change
    change_column :alayacare_form_answers, :reply, :text
  end
end
