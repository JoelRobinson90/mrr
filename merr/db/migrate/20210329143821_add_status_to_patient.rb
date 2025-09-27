# typed: false
class AddStatusToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :status, :string, default: "Created", null: false
  end
end
