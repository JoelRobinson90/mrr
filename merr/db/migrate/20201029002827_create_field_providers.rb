# typed: true
class CreateFieldProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :field_providers do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.date :date_of_birth
      t.references :field_org, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.string :provider_level
      t.string :avatar
      t.string :bio
      
      t.timestamps
    end
  end
end
