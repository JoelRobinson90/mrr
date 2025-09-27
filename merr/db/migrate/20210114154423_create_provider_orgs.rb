# typed: true
class CreateProviderOrgs < ActiveRecord::Migration[6.0]
  def change
    create_table :provider_orgs do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
