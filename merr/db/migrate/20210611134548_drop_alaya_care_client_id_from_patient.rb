class DropAlayaCareClientIdFromPatient < ActiveRecord::Migration[6.1]
  def change
    remove_column :patients, :alayacare_client_blob, :json
  end
end
