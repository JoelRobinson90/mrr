# typed: false
class DropWorkpathInvites < ActiveRecord::Migration[6.0]
  def change
    drop_table :workpath_invites do |t|
      t.references :account, polymorphic: true, null: false
      t.references :inviter, foreign_key: { to_table: :users }
      t.bigint :workpath_invite_id, index: true, null: false
      t.string :workpath_invite_slug, null: false
      t.datetime :responded_at

      t.timestamps
    end
  end
end
