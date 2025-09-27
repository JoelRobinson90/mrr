class AddDatalakeIdToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :datalake_id, :string
  end
end
