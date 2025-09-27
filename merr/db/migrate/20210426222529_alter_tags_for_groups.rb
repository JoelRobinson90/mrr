# typed: false
class AlterTagsForGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :description, :string
    add_column :tags, :group, :string
    add_column :tags, :color, :string, default: "#FFF", null: false
  end
end
