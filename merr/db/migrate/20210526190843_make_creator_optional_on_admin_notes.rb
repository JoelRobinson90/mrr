# typed: false
class MakeCreatorOptionalOnAdminNotes < ActiveRecord::Migration[6.1]
  def change
    change_column :admin_notes, :creator_id, :integer, null: true
  end
end
