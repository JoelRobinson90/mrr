# typed: true
class CreateProviderOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :provider_organizations do |t|
      t.string :name
      t.string :logo

      t.timestamps
    end
  end
end
