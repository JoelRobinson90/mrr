class DemandPartnerAddAcId < ActiveRecord::Migration[6.1]
  def change
    add_column :demand_partners, :alayacare_id, :int
  end
end
