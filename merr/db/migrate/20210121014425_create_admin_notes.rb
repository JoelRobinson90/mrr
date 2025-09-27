# typed: true
class CreateAdminNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_notes do |t|
      t.string :content
      t.references :notable, null: false, polymorphic: true
      t.references :creator, null: false, foreign_key: { to_table: 'users' }

      t.timestamps
    end
  end
end
