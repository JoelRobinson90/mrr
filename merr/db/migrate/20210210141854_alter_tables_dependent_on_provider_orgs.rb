# typed: false
class AlterTablesDependentOnProviderOrgs < ActiveRecord::Migration[6.0]
  def change
    rename_column :patients, :provider_org_id, :demand_partner_id
  end
end
