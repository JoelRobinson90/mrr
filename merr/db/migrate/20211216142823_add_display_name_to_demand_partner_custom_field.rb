# frozen_string_literal: true

class AddDisplayNameToDemandPartnerCustomField < ActiveRecord::Migration[6.1]
  def change
    add_column :demand_partner_custom_fields, :display_name, :string, null: true
  end
end
