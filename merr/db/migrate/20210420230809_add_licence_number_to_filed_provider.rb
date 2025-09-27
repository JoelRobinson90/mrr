# typed: false
class AddLicenceNumberToFiledProvider < ActiveRecord::Migration[6.1]
  def change
    add_column :field_providers, :license_number, :string
  end
end
