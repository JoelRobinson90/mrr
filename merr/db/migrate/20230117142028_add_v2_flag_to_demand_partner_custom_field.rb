class AddV2FlagToDemandPartnerCustomField < ActiveRecord::Migration[6.1]
  def change
    add_column :demand_partner_custom_fields, :v2, :boolean
  end
end
