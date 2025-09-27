# frozen_string_literal: true

class CreateDemandPartnerCustomFields < ActiveRecord::Migration[6.1]
  def change
    create_table :demand_partner_custom_fields do |t|
      t.string :csv_column_name, null: false
      t.string :crm_field_name
      t.belongs_to :demand_partner, null: true, foreign_key: true
      t.string :data_type, null: false

      t.timestamps
    end
  end
end
