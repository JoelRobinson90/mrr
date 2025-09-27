# frozen_string_literal: true

class AddMaIdToAdminNote < ActiveRecord::Migration[6.1]
  def up
    add_column :admin_notes, :ma_id, :string

    add_index :admin_notes, :ma_id

    create_sequence :admin_note_ma_id
  end

  def down
    remove_column :admin_notes, :ma_id

    drop_sequence :admin_note_ma_id
  end
end
