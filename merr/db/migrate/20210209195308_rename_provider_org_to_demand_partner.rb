# typed: false
class RenameProviderOrgToDemandPartner < ActiveRecord::Migration[6.0]
  def change
    rename_table :provider_orgs, :demand_partners
  end
end
