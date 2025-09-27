# typed: false
class AddRedoxProviderIdToDemandPartner < ActiveRecord::Migration[6.0]
  def change
    add_column :demand_partners, :redox_provider_id, :string
  end
end
