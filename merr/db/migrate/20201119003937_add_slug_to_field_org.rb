# typed: false
class AddSlugToFieldOrg < ActiveRecord::Migration[6.0]
  def change
    add_column :field_orgs, :slug, :string, index: true

    FieldOrg.find_each do |org|
      org.generate_slug
      org.save!
    end

    change_column_null :field_orgs, :slug, false
  end
end
