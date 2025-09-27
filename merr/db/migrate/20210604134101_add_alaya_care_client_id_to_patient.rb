class AddAlayaCareClientIdToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :alayacare_client_blob, :json
  end
end
