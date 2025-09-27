# frozen_string_literal: true

class CreateCustomFieldResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :custom_field_responses do |t|
      t.string :value
      t.references :patient
      t.references :demand_partner_custom_field
      t.timestamps
    end
  end
end
