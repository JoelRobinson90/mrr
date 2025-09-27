# typed: false
class RemoveInsuranceFieldsFromPatient < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :patients, :insurance_company
    remove_column :patients, :insurance_group_number
    remove_column :patients, :insurance_member_number
    remove_column :patients, :insurance_type
  end

  def self.down
    add_column :patients, :insurance_company,       :string
    add_column :patients, :insurance_group_number,  :string
    add_column :patients, :insurance_member_number, :string
    add_column :patients, :insurance_type,          :string
  end
end
