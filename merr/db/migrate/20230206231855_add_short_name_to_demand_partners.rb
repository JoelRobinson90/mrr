class AddShortNameToDemandPartners < ActiveRecord::Migration[6.1]
  def up
    add_column :demand_partners, :short_name, :string

    DemandPartner.all.each do |demand_partner|
      demand_partner.update_columns(short_name: demand_partner.name)
    end

    change_column_null :demand_partners, :short_name, false
  end

  def down
    remove_column :demand_partners, :short_name, :string
  end
end
