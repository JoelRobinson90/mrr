# typed: false
class CreateProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :providers do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :certification
      t.references :user, index: true, foreign_key: true, null: false, index: { unique: true }
      t.string :drchrono_id
      t.string :drchrono_access_token
      t.string :drchrono_refresh_token
      t.datetime :drchrono_token_expires
      t.string :workpath_id
      t.string :workpath_access_token
      t.string :workpath_refresh_token
      t.datetime :workpath_token_expires

      t.timestamps
    end
  end
end
