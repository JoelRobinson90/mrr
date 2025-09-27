# frozen_string_literal: true

class CreateProgramVisitTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :program_visit_types do |t|
      t.references :program, index: false
      t.references :visit_type, index: false
      t.timestamps

      t.index %i[visit_type_id program_id]
      t.index %i[program_id visit_type_id]
    end
  end
end
