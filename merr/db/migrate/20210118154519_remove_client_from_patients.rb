# typed: false
class RemoveClientFromPatients < ActiveRecord::Migration[6.0]
  def change
    remove_reference :patients, :client, null: false, foreign_key: {on_delete: :cascade}
  end
end
