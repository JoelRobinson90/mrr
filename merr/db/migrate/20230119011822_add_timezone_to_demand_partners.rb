class AddTimezoneToDemandPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :demand_partners, :timezone, :string
  end
end
