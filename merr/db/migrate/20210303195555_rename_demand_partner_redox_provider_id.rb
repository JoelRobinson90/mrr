# typed: false
class RenameDemandPartnerRedoxProviderId < ActiveRecord::Migration[6.0]
  def change
    rename_column :demand_partners, :redox_provider_id, :redox_source_id
  end
end
