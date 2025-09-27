# typed: false
class AddPhoneNumberToMedarriveAdmins < ActiveRecord::Migration[6.0]
  def change
    add_column :medarrive_admins, :phone_number, :string
  end
end
