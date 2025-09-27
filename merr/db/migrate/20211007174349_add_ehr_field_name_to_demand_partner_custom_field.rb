# frozen_string_literal: true

class AddEhrFieldNameToDemandPartnerCustomField < ActiveRecord::Migration[6.1]
  def change
    add_column :demand_partner_custom_fields, :ehr_field_name, :string
  end
end
