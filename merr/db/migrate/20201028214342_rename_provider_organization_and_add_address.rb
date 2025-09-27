# typed: false
class RenameProviderOrganizationAndAddAddress < ActiveRecord::Migration[6.0]
  def change
  	rename_table :provider_organizations, :field_orgs

  	add_reference :field_orgs, :address, null: true, foreign_key: true
  end
end
