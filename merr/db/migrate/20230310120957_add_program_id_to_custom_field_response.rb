class AddProgramIdToCustomFieldResponse < ActiveRecord::Migration[6.1]
  def change
    add_reference :custom_field_responses, :program, null: true, foreign_key: true
  end
end
