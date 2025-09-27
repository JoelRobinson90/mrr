# typed: false
class AlterDefaultAndNotNilOfTagGroup < ActiveRecord::Migration[6.1]
  def change
    remove_column :tags, :group
    add_column :tags, :group, :string, default: "Appointment", null: false
  end
end
