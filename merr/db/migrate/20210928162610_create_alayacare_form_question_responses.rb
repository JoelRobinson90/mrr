class CreateAlayacareFormQuestionResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :alayacare_form_answers do |t|
      t.references :alayacare_form_response, null: false, foreign_key: true, index: {name: :alayacare_form_response_answer_index}
      t.string :field_tag
      t.string :response
      t.string :processor
      t.text :question

      t.timestamps
    end
  end
end
