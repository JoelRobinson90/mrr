# typed: true
# frozen_string_literal: true

class CreateClinicalSummaries < ActiveRecord::Migration[6.0]
  def change
    create_table :redox_clinical_summaries do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :demand_partner, null: false, foreign_key: true
      t.json :redox_object

      t.timestamps
    end
  end
end
